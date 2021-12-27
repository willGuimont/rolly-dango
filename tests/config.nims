import os

switch("path", "$projectDir/../src")

let buildDir = currentSourcePath().parentDir.parentDir / "buildTests"
switch("outdir", buildDir)
