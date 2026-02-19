/**
 * Firebase Functions - Maintenance Monitoring
 */

import { initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import * as admin from "firebase-admin";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { setGlobalOptions } from "firebase-functions";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { DateTime } from "luxon";

initializeApp();
const db = getFirestore();

setGlobalOptions({ maxInstances: 10 });

/* ===============================
   HELPER FUNCTIONS
================================ */

/* ===============================
   1️⃣ CREATE DAILY SNAPSHOT
   Runs every day at 00:05 WITA
================================ */

export const createDailyMaintenanceSnapshot = onSchedule(
  {
    schedule: "5 0 * * *",
    // schedule: "*/2 * * * *",
    timeZone: "Asia/Makassar",
    region: "asia-southeast2",
  },
  async () => {
    try {
      // 🔒 Gunakan timezone eksplisit
      const now = DateTime.now().setZone("Asia/Makassar");

      const docId = now.toFormat("yyyy-MM-dd");

      const snapshotRef = db
        .collection("daily_maintenance_snapshot")
        .doc(docId);

      // Prevent duplicate snapshot
      const existing = await snapshotRef.get();
      if (existing.exists) {
        console.log(`Snapshot ${docId} already exists`);
        return;
      }

      // 🔥 Start & End of day berdasarkan Asia/Makassar
      const start = now.startOf("day").toJSDate();
      const end = now.endOf("day").toJSDate();

      const startTimestamp = Timestamp.fromDate(start);
      const endTimestamp = Timestamp.fromDate(end);

      // 1️⃣ Due Today
      const dueTodaySnap = await db
        .collection("maintenance")
        .where("nextMaintenanceAt", ">=", startTimestamp)
        .where("nextMaintenanceAt", "<=", endTimestamp)
        .get();

      const totalDueToday = dueTodaySnap.size;

      // 2️⃣ Overdue
      const overdueSnap = await db
        .collection("maintenance")
        .where("nextMaintenanceAt", "<", startTimestamp)
        .get();

      const totalOverdue = overdueSnap.size;

      await snapshotRef.set({
        totalDueToday,
        totalOverdue,
        createdAt: Timestamp.now(), // lebih aman
        notificationSent: false,
        timezone: "Asia/Makassar", // optional untuk audit
      });

      console.log(`Snapshot ${docId} created`, {
        totalDueToday,
        totalOverdue,
      });
    } catch (error) {
      console.error("Snapshot creation failed", error);
    }
  },
);

/* ===============================
   2️⃣ SEND NOTIFICATION
   Runs every day at 08:00 WITA
================================ */

export const sendMaintenanceNotification = onSchedule(
  {
    schedule: "0 8 * * *",
    // schedule: "*/2 * * * *",
    timeZone: "Asia/Makassar",
    region: "asia-southeast2",
  },
  async () => {
    try {
      // ✅ Timezone-safe
      const now = DateTime.now().setZone("Asia/Makassar");
      const docId = now.toFormat("yyyy-MM-dd");

      const snapshotRef = db
        .collection("daily_maintenance_snapshot")
        .doc(docId);

      const doc = await snapshotRef.get();

      if (!doc.exists) {
        console.log("Snapshot not found");
        return;
      }

      const data = doc.data();
      const totalDueToday = data?.totalDueToday ?? 0;
      const totalOverdue = data?.totalOverdue ?? 0;
      const alreadySent = data?.notificationSent ?? false;

      if (alreadySent) {
        console.log("Notification already sent today");
        return;
      }

      if (totalDueToday === 0 && totalOverdue === 0) {
        console.log("No maintenance today");
        return;
      }

      let messageBody = "";

      if (totalDueToday > 0) {
        messageBody += `${totalDueToday} item perlu dirawat hari ini`;
      }

      if (totalOverdue > 0) {
        if (messageBody.length > 0) messageBody += " dan ";
        messageBody += `${totalOverdue} item terlambat`;
      }

      messageBody += ". Silakan lakukan pengecekan.";

      await admin.messaging().send({
        topic: "maintenance",
        android: { priority: "high" },
        notification: {
          title: "Pengingat Maintenance",
          body: messageBody,
        },
      });

      await snapshotRef.update({
        notificationSent: true,
        notificationSentAt: admin.firestore.FieldValue.serverTimestamp(),
        notificationStatus: "success",
      });

      console.log("Notification sent successfully");
    } catch (error) {
      console.error("Notification failed", error);
    }
  },
);

/* ===============================
   3️⃣ NOTIFY OUT OF STOCK
   Triggered when stock becomes 0
================================ */

export const notifyOutOfStock = onDocumentUpdated(
  {
    document: "items/{itemId}",
    region: "asia-southeast2",
  },
  async (event) => {
    try {
      const before = event.data?.before.data();
      const after = event.data?.after.data();

      if (!before || !after) return;

      const beforeStock = before.stock ?? 0;
      const afterStock = after.stock ?? 0;

      // 🔒 Trigger hanya jika berubah dari >0 menjadi 0
      if (beforeStock > 0 && afterStock === 0) {
        await admin.messaging().send({
          topic: "stock",
          android: { priority: "high" },
          notification: {
            title: "Stok Habis",
            body: `${after.name} telah habis.`,
          },
        });

        console.log(`Out of stock notification sent for ${after.name}`);
      }
    } catch (error) {
      console.error("Out of stock notification failed", error);
    }
  },
);
