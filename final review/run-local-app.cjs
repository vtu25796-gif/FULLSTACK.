const { spawn } = require("child_process");
const path = require("path");
const http = require("http");

const rootDir = path.resolve(__dirname, "..");
const frontendDir = path.join(rootDir, "frontend");
const backendDir = path.join(rootDir, "backend");
const prodAppUrl = "http://127.0.0.1:5000";
const devAppUrl = "http://127.0.0.1:5173";
const healthUrl = `${prodAppUrl}/api/health`;
const isWindows = process.platform === "win32";

let backendProcess = null;
let shuttingDown = false;

function runCommand(command, args, options = {}) {
  return new Promise((resolve, reject) => {
    const child = spawn(command, args, {
      cwd: options.cwd || rootDir,
      env: { ...process.env, ...(options.env || {}) },
      stdio: "inherit",
      shell: false
    });

    child.on("error", reject);
    child.on("exit", (code) => {
      if (code === 0) {
        resolve();
        return;
      }

      reject(new Error(`${command} ${args.join(" ")} exited with code ${code}`));
    });
  });
}

function waitForServer(url, timeoutMs = 30000) {
  const startedAt = Date.now();

  return new Promise((resolve, reject) => {
    const attempt = () => {
      const req = http.get(url, (res) => {
        res.resume();
        if (res.statusCode && res.statusCode >= 200 && res.statusCode < 500) {
          resolve();
          return;
        }

        if (Date.now() - startedAt >= timeoutMs) {
          reject(new Error("Timed out waiting for the app to start"));
          return;
        }

        setTimeout(attempt, 1000);
      });

      req.on("error", () => {
        if (Date.now() - startedAt >= timeoutMs) {
          reject(new Error("Timed out waiting for the app to start"));
          return;
        }

        setTimeout(attempt, 1000);
      });
    };

    attempt();
  });
}

function isServerReady(url) {
  return new Promise((resolve) => {
    const req = http.get(url, (res) => {
      res.resume();
      resolve(Boolean(res.statusCode && res.statusCode >= 200 && res.statusCode < 500));
    });

    req.on("error", () => resolve(false));
  });
}

function fetchText(url) {
  return new Promise((resolve) => {
    const req = http.get(url, (res) => {
      let body = "";
      res.setEncoding("utf8");
      res.on("data", (chunk) => {
        body += chunk;
      });
      res.on("end", () => {
        resolve({
          ok: Boolean(res.statusCode && res.statusCode >= 200 && res.statusCode < 500),
          statusCode: res.statusCode || 0,
          body
        });
      });
    });

    req.on("error", () => resolve({ ok: false, statusCode: 0, body: "" }));
  });
}

async function resolveOpenUrl() {
  const devReady = await isServerReady(devAppUrl);
  if (devReady) {
    return devAppUrl;
  }

  const prodRoot = await fetchText(prodAppUrl);
  if (prodRoot.ok && /<!doctype html|<html/i.test(prodRoot.body)) {
    return prodAppUrl;
  }

  return null;
}

function openBrowser(url) {
  if (isWindows) {
    spawn("cmd", ["/c", "start", "", url], { detached: true, stdio: "ignore" }).unref();
    return;
  }

  if (process.platform === "darwin") {
    spawn("open", [url], { detached: true, stdio: "ignore" }).unref();
    return;
  }

  spawn("xdg-open", [url], { detached: true, stdio: "ignore" }).unref();
}

function shutdown() {
  if (shuttingDown) return;
  shuttingDown = true;

  if (backendProcess && !backendProcess.killed) {
    backendProcess.kill();
  }

  process.exit(0);
}

async function main() {
  const existingUrl = await resolveOpenUrl();
  if (existingUrl) {
    console.log("The app is already running. Opening it now...");
    openBrowser(existingUrl);
    return;
  }

  console.log("Building the React app...");
  const buildCommand = isWindows ? "cmd.exe" : "npm";
  const buildArgs = isWindows ? ["/c", "npm", "run", "build"] : ["run", "build"];
  await runCommand(buildCommand, buildArgs, { cwd: frontendDir });

  console.log("Starting the app...");
  backendProcess = spawn("node", ["src/server.js"], {
    cwd: backendDir,
    env: {
      ...process.env,
      NODE_ENV: "production",
      PORT: "5000",
      CLIENT_URL: prodAppUrl,
      FRONTEND_DIST_PATH: path.join(frontendDir, "dist")
    },
    stdio: "inherit",
    shell: false
  });

  backendProcess.on("exit", (code) => {
    if (!shuttingDown && code !== 0) {
      console.error(`Backend stopped with code ${code}`);
      process.exit(code || 1);
    }
  });

  await waitForServer(healthUrl);
  console.log(`Opening ${prodAppUrl}`);
  openBrowser(prodAppUrl);
  console.log("The app is running. Press Ctrl+C to stop it.");
}

process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);

main().catch((error) => {
  console.error(error.message);
  shutdown();
});
