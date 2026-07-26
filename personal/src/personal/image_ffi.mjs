import { spawnSync } from "node:child_process"

const image = "dpokidov/imagemagick:7.1.1-47@sha256:dac6411fae7541908d9881c0c27c205d07010d896184e27b52d4cfc2261e4803"
export function runAll(commands) {
  const projectDirectory = process.env.HOST_PROJECT_DIR || process.cwd()
  const result = spawnSync(
    "docker",
    [
      "run", "--rm", "-i",
      "-v", `${projectDirectory}:/work`,
      "-w", "/work",
      "--entrypoint", "sh",
      image,
      "-ec", commands,
    ],
    { stdio: "inherit" },
  )

  if (result.status !== 0) {
    return false
  }
  return true
}
