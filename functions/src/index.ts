import {initializeApp} from "firebase-admin/app";
import {FieldValue, getFirestore} from "firebase-admin/firestore";
import {defineSecret} from "firebase-functions/params";
import {onSchedule} from "firebase-functions/v2/scheduler";
import {logger} from "firebase-functions";

import {sendLiveActivityUpdate} from "./apns.js";
import {
  LiveActivityDocument,
  Plan,
  scheduledContent,
} from "./live_activity_state.js";

initializeApp();

const apnsPrivateKey = defineSecret("APNS_KEY_P8");
const apnsKeyId = defineSecret("APNS_KEY_ID");
const appleTeamId = defineSecret("APPLE_TEAM_ID");

export const updateScheduledLiveActivities = onSchedule(
  {
    schedule: "every 1 minutes",
    timeZone: "UTC",
    region: "asia-northeast3",
    timeoutSeconds: 120,
    secrets: [apnsPrivateKey, apnsKeyId, appleTeamId],
  },
  async () => {
    const database = getFirestore();
    const snapshot = await database
      .collectionGroup("liveActivities")
      .where("active", "==", true)
      .get();
    const now = new Date();

    await Promise.all(snapshot.docs.map(async (tokenDocument) => {
      const userDocument = tokenDocument.ref.parent.parent;
      if (userDocument === null) return;
      const token = tokenDocument.data() as LiveActivityDocument & {
        pushToken?: string;
        bundleId?: string;
        apnsEnvironment?: string;
        timeZone?: string;
        lastSentSignature?: string;
        remoteUpdatesEnabled?: boolean;
      };
      if (!token.pushToken || !token.bundleId) return;
      if (token.remoteUpdatesEnabled === false) return;

      const userSnapshot = await userDocument.get();
      const plan = (userSnapshot.data()?.latestPlan ?? {}) as Plan;
      const next = scheduledContent(
        now,
        token.timeZone ?? "UTC",
        plan,
        token,
      );
      if (next.signature === token.lastSentSignature) return;

      const result = await sendLiveActivityUpdate(
        {
          keyId: apnsKeyId.value(),
          teamId: appleTeamId.value(),
          privateKey: apnsPrivateKey.value(),
        },
        {
          token: token.pushToken,
          bundleId: token.bundleId,
          environment: token.apnsEnvironment === "sandbox" ?
            "sandbox" : "production",
          contentState: next.contentState,
        },
      );

      if (result.status >= 200 && result.status < 300) {
        await tokenDocument.ref.set({
          lastSentSignature: next.signature,
          lastSentAt: FieldValue.serverTimestamp(),
          lastApnsStatus: result.status,
        }, {merge: true});
        return;
      }

      const invalidToken = result.status === 410 ||
        result.reason === "BadDeviceToken" ||
        result.reason === "DeviceTokenNotForTopic";
      await tokenDocument.ref.set({
        active: invalidToken ? false : true,
        lastApnsStatus: result.status,
        lastApnsReason: result.reason ?? "unknown",
        lastAttemptAt: FieldValue.serverTimestamp(),
      }, {merge: true});
      logger.warn("Live Activity APNs update failed", {
        activityId: tokenDocument.id,
        status: result.status,
        reason: result.reason,
      });
    }));
  },
);
