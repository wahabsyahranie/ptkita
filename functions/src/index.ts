/**
 * Firebase Functions - Maintenance Monitoring
 */

import { initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import * as admin from "firebase-admin";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { setGlobalOptions } from "firebase-functions";

initializeApp();
const db = getFirestore();

setGlobalOptions({ maxInstances: 10 });

/* ===============================
   HELPER FUNCTIONS
================================ */

function todayDocId(date: Date): string {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, "0");
  const d = String(date.getDate()).padStart(2, "0");
  return `${y}-${m}-${d}`;
}

function startOfDay(date: Date): Date {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0);
}

function endOfDay(date: Date): Date {
  return new Date(
    date.getFullYear(),
    date.getMonth(),
    date.getDate(),
    23,
    59,
    59,
    999,
  );
}

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
      const now = new Date();
      const docId = todayDocId(now);

      const snapshotRef = db
        .collection("daily_maintenance_snapshot")
        .doc(docId);

      // 🔒 Prevent duplicate snapshot
      const existing = await snapshotRef.get();
      if (existing.exists) {
        console.log(`Snapshot ${docId} already exists`);
        return;
      }

      const start = Timestamp.fromDate(startOfDay(now));
      const end = Timestamp.fromDate(endOfDay(now));

      // 1️⃣ Due Today
      const dueTodaySnap = await db
        .collection("maintenance")
        .where("nextMaintenanceAt", ">=", start)
        .where("nextMaintenanceAt", "<=", end)
        .get();

      const totalDueToday = dueTodaySnap.size;

      // 2️⃣ Overdue
      const overdueSnap = await db
        .collection("maintenance")
        .where("nextMaintenanceAt", "<", start)
        .get();

      const totalOverdue = overdueSnap.size;

      await snapshotRef.set({
        totalDueToday,
        totalOverdue,
        createdAt: Timestamp.fromDate(now),
        notificationSent: false,
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
      const now = new Date();
      const docId = todayDocId(now);

      const snapshotRef = admin
        .firestore()
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

      // 🔒 Prevent duplicate notification
      if (alreadySent) {
        console.log("Notification already sent today");
        return;
      }

      // If nothing to notify
      if (totalDueToday === 0 && totalOverdue === 0) {
        console.log("No maintenance today");
        return;
      }

      // 🔥 Build dynamic message
      let messageBody = "";

      if (totalDueToday > 0) {
        messageBody += `${totalDueToday} item perlu dirawat hari ini`;
      }

      if (totalOverdue > 0) {
        if (messageBody.length > 0) messageBody += " dan ";
        messageBody += `${totalOverdue} item terlambat`;
      }

      messageBody += ". Silakan lakukan pengecekan.";

      // 🚀 Send FCM
      await admin.messaging().send({
        topic: "maintenance",
        android: {
          priority: "high",
        },
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
