#!/usr/bin/env python3
"""Drake forward dynamics (MultibodyPlant)."""
import numpy as np
from pydrake.math import RigidTransform
from pydrake.multibody.plant import MultibodyPlant
from pydrake.multibody.tree import FixedOffsetFrame, RevoluteJoint, RotationalInertia, SpatialInertia

import acrobot_benchmark as acrobot

plant = MultibodyPlant(0.0)
link1 = plant.AddRigidBody("Link1", SpatialInertia.MakeFromCentralInertia(
    acrobot.MASS, [0, 0, -acrobot.COM1], RotationalInertia(*acrobot.INERTIA1)))
link2 = plant.AddRigidBody("Link2", SpatialInertia.MakeFromCentralInertia(
    acrobot.MASS, [0, 0, -acrobot.COM2], RotationalInertia(*acrobot.INERTIA2)))
elbow = plant.AddFrame(FixedOffsetFrame("elbow", link1.body_frame(), RigidTransform([0, 0, -acrobot.LINK1_LENGTH])))
plant.AddJoint(RevoluteJoint("ShoulderJoint", plant.world_frame(), link1.body_frame(), [1, 0, 0], damping=acrobot.DAMPING))
plant.AddJoint(RevoluteJoint("ElbowJoint", elbow, link2.body_frame(), [1, 0, 0], damping=acrobot.DAMPING))
plant.mutable_gravity_field().set_gravity_vector([0, 0, -acrobot.GRAVITY])
plant.Finalize()
context = plant.CreateDefaultContext()


def acceleration(q, v):
    plant.SetPositions(context, q)
    plant.SetVelocities(context, v)
    return np.array(plant.EvalTimeDerivatives(context).get_generalized_velocity().CopyToVector())


if __name__ == "__main__":
    raise SystemExit(acrobot.run("drake", acceleration))
