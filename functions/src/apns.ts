import http2 from "node:http2";

import {importPKCS8, SignJWT} from "jose";

export type ApnsConfiguration = {
  keyId: string;
  teamId: string;
  privateKey: string;
};

export type LiveActivityPush = {
  token: string;
  bundleId: string;
  environment: "sandbox" | "production";
  contentState: Record<string, unknown>;
};

export type ApnsResult = {
  status: number;
  reason?: string;
};

let cachedAuthorization: {value: string; createdAt: number} | undefined;

export async function sendLiveActivityUpdate(
  configuration: ApnsConfiguration,
  push: LiveActivityPush,
): Promise<ApnsResult> {
  const authorization = await bearerToken(configuration);
  const authority = push.environment === "sandbox" ?
    "https://api.sandbox.push.apple.com" :
    "https://api.push.apple.com";
  const client = http2.connect(authority);

  try {
    return await new Promise<ApnsResult>((resolve, reject) => {
      const request = client.request({
        ":method": "POST",
        ":path": `/3/device/${push.token}`,
        "authorization": `bearer ${authorization}`,
        "apns-topic": `${push.bundleId}.push-type.liveactivity`,
        "apns-push-type": "liveactivity",
        // 카드 경계 갱신은 즉시성이 중요하므로 priority 10을 사용한다.
        "apns-priority": "10",
      });
      const chunks: Buffer[] = [];
      request.on("response", (headers) => {
        const status = Number(headers[":status"] ?? 500);
        request.on("data", (chunk: Buffer) => chunks.push(chunk));
        request.on("end", () => {
          const body = Buffer.concat(chunks).toString("utf8");
          let reason: string | undefined;
          if (body !== "") {
            try {
              reason = (JSON.parse(body) as {reason?: string}).reason;
            } catch {
              reason = body;
            }
          }
          resolve({status, reason});
        });
      });
      request.on("error", reject);
      request.end(JSON.stringify({
        aps: {
          timestamp: Math.floor(Date.now() / 1000),
          event: "update",
          "content-state": push.contentState,
        },
      }));
    });
  } finally {
    client.close();
  }
}

async function bearerToken(
  configuration: ApnsConfiguration,
): Promise<string> {
  const now = Date.now();
  if (cachedAuthorization !== undefined &&
      now - cachedAuthorization.createdAt < 50 * 60 * 1000) {
    return cachedAuthorization.value;
  }
  const normalizedKey = configuration.privateKey.replace(/\\n/g, "\n");
  const key = await importPKCS8(normalizedKey, "ES256");
  const value = await new SignJWT({})
    .setProtectedHeader({alg: "ES256", kid: configuration.keyId})
    .setIssuer(configuration.teamId)
    .setIssuedAt()
    .sign(key);
  cachedAuthorization = {value, createdAt: now};
  return value;
}
