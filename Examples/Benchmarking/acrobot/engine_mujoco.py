#!/usr/bin/env python3
"""MuJoCo forward dynamics."""
import mujoco
import numpy as np

import acrobot_benchmark as acrobot

MODEL = f"""
<mujoco model="acrobot">
  <option gravity="0 0 -{acrobot.GRAVITY}"/>
  <worldbody>
    <body name="Link1">
      <joint name="ShoulderJoint" type="hinge" axis="1 0 0" damping="{acrobot.DAMPING}"/>
      <inertial pos="0 0 -{acrobot.COM1}" mass="{acrobot.MASS}" diaginertia="{' '.join(map(str, acrobot.INERTIA1))}"/>
      <body name="Link2" pos="0 0 -{acrobot.LINK1_LENGTH}">
        <joint name="ElbowJoint" type="hinge" axis="1 0 0" damping="{acrobot.DAMPING}"/>
        <inertial pos="0 0 -{acrobot.COM2}" mass="{acrobot.MASS}" diaginertia="{' '.join(map(str, acrobot.INERTIA2))}"/>
      </body>
    </body>
  </worldbody>
</mujoco>
"""

model = mujoco.MjModel.from_xml_string(MODEL)
data = mujoco.MjData(model)


def acceleration(q, v):
    data.qpos[:] = q
    data.qvel[:] = v
    mujoco.mj_forward(model, data)
    return np.array(data.qacc)


if __name__ == "__main__":
    raise SystemExit(acrobot.run("mujoco", acceleration))
