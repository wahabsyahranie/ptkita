/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */
import { initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp } from "firebase-admin/firestore";

import { setGlobalOptions } from "firebase-functions";
// import { onRequest } from "firebase-functions/https";
// import * as logger from "firebase-functions/logger";

// Start writing functions
initializeApp();
const db = getFirestore();

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

//CLOUD FUNCTION (MANUAL)
import { onRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

export const createDailyMaintenanceSnapshot = onRequest(
  { region: "asia-southeast2" },
  async (req, res) => {
    try {
      const now = new Date();

      const docId = todayDocId(now);
      const snapshotRef = db
        .collection("daily_maintenance_snapshot")
        .doc(docId);

      // 🔒 Cegah double create
      const existing = await snapshotRef.get();
      if (existing.exists) {
        logger.info(`Snapshot ${docId} already exists`);
        res.status(200).send({
          message: "Snapshot already exists",
          docId,
        });
        return;
      }

      const start = Timestamp.fromDate(startOfDay(now));
      const end = Timestamp.fromDate(endOfDay(now));

      const maintenanceSnap = await db
        .collection("maintenance")
        .where("nextMaintenanceAt", ">=", start)
        .where("nextMaintenanceAt", "<=", end)
        .get();

      const totalScheduled = maintenanceSnap.size;

      await snapshotRef.set({
        totalScheduled,
        createdAt: Timestamp.now(),
      });

      logger.info(`Snapshot ${docId} created`, { totalScheduled });

      res.status(200).send({
        message: "Snapshot created",
        docId,
        totalScheduled,
      });
    } catch (error) {
      logger.error("Snapshot creation failed", error);
      res.status(500).send("Error creating snapshot");
    }
  },
);

// https://firebase.google.com/docs/functions/typescript

// For cost control, you can set the maximum number of containers that can be
// running at the same time. This helps mitigate the impact of unexpected
// traffic spikes by instead downgrading performance. This limit is a
// per-function limit. You can override the limit for each function using the
// `maxInstances` option in the function's options, e.g.
// `onRequest({ maxInstances: 5 }, (req, res) => { ... })`.
// NOTE: setGlobalOptions does not apply to functions using the v1 API. V1
// functions should each use functions.runWith({ maxInstances: 10 }) instead.
// In the v1 API, each function can only serve one request per container, so
// this will be the maximum concurrent request count.
setGlobalOptions({ maxInstances: 10 });

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
