const { spawn } = require("child_process");
const path = require("path");
const http = require("http");

const rootDir = path.resolve(__dirname, "..");
const backendDir = path.join(rootDir, "backend");
const frontendDir = path.join(rootDir, "frontend");
const isWindows = process.platform === "win32";
const backendUrl = "http://localhost:5000";
const frontendUrl = "http://localhost:5173";

let backendProcess = null;
let frontendProcess = null;
let shuttingDown = false;
let keepAliveTimer = null;

function spawnChild(command, args, cwd) {
  return spawn(command, args, {
    cwd,
    env: { ...process.env },
    stdio: "inherit",
    shell: false,
    windowsHide: false
  });
}

function isServerReady(url) {
  return new Promise((resolve) => {
    const req = http.get(url, (res) => {
      res.resume();
      resolve(Boolean(res.statusCode && res.statusCode >= 200 && res.statusCode < 500));
    });

    req.on("error", () => resolve(false));
    req.setTimeout(1500, () => {
      req.destroy();
      resolve(false);
    });
  });
}

function waitForServer(url, timeoutMs = 30000) {
  const startedAt = Date.now();

  return new Promise((resolve, reject) => {
    const attempt = async () => {
      if (await isServerReady(url)) {
        resolve();
        return;
      }

      if (Date.now() - startedAt >= timeoutMs) {
        reject(new Error(`Timed out waiting for ${url}`));
        return;
      }

      setTimeout(attempt, 1000);
    };

    attempt();
  });
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

function shutdown(exitCode = 0) {
  if (shuttingDown) {
    return;
  }

  shuttingDown = true;

  if (keepAliveTimer) {
    clearInterval(keepAliveTimer);
  }

  if (frontendProcess && !frontendProcess.killed) {
    frontendProcess.kill();
  }

  if (backendProcess && !backendProcess.killed) {
    backendProcess.kill();
  }

  process.exit(exitCode);
}

function handleChildExit(name, code) {
  if (shuttingDown) {
    return;
  }

  if (code && code !== 0) {
    console.error(`${name} exited with code ${code}`);
    shutdown(code);
    return;
  }

  console.log(`${name} stopped.`);
  shutdown(0);
}

async function main() {
  const backendReady = await isServerReady(`${backendUrl}/api/health`);
  const frontendReady = await isServerReady(frontendUrl);

  if (backendReady && frontendReady) {
    console.log("The app is already running.");
    console.log(`Open ${frontendUrl}`);
    openBrowser(frontendUrl);
    console.log("Press Ctrl+C to close this launcher.");
    keepAliveTimer = setInterval(() => {}, 60 * 60 * 1000);
    return;
  }

  console.log(`Starting backend on ${backendUrl} and frontend on ${frontendUrl}...`);

  if (!backendReady) {
    backendProcess = spawnChild(process.execPath, ["src/server.js"], backendDir);
  } else {
    console.log(`Backend is already running on ${backendUrl}`);
  }

  if (!frontendReady) {
    frontendProcess = isWindows
      ? spawnChild("cmd.exe", ["/c", "npm", "run", "dev"], frontendDir)
      : spawnChild("npm", ["run", "dev"], frontendDir);
  } else {
    console.log(`Frontend is already running on ${frontendUrl}`);
  }

  if (backendProcess) {
    backendProcess.on("error", (error) => {
      console.error(`Failed to start backend: ${error.message}`);
      shutdown(1);
    });

    backendProcess.on("exit", (code) => handleChildExit("Backend", code));
  }

  if (frontendProcess) {
    frontendProcess.on("error", (error) => {
      console.error(`Failed to start frontend: ${error.message}`);
      shutdown(1);
    });

    frontendProcess.on("exit", (code) => handleChildExit("Frontend", code));
  }

  await waitForServer(frontendUrl);
  console.log(`Opening ${frontendUrl}`);
  openBrowser(frontendUrl);
}

process.on("SIGINT", () => shutdown(0));
process.on("SIGTERM", () => shutdown(0));

main().catch((error) => {
  console.error(error.message);
  shutdown(1);
});
