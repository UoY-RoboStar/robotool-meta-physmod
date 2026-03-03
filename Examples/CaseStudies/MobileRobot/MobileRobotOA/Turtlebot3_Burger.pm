// Simplified Turtlebot3 Burger physical model for the SKO pipeline.
// Uses two controlled wheel joints and minimal inertial parameters.

import physmod::math::*
import physmod::SKO::joints::Revolute_y
import physmod::trivial::actuators::ControlledMotor 

pmodel Turtlebot3_Burger {
	local link BaseLink {
		def { }
		local body Chassis {
			def {
				inertial information {
					mass 0.82573504
					inertia matrix { ixx 0.72397393 ixy 0.0000000004686399 ixz -0.0000000109525703 iyy 0.72397393 iyz 0.0000000028582649 izz 0.653050163 }
					pose { x = -0.032 y = 0.0 z = 0.070 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				mesh {
					shape "meshes/bases/burger_base.stl"
					scaling 0.001
				}
			}
			pose { x = -0.032 y = 0.0 z = 0.070 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}

		jref LeftWheelJoint = Revolute_y {
			flexibly connected to LeftWheel
			pose { x = 0.0 y = 0.08 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
			aref LeftMotor = ControlledMotor {
				pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
			}
		}

		jref RightWheelJoint = Revolute_y {
			flexibly connected to RightWheel
			pose { x = 0.0 y = -0.08 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
			aref RightMotor = ControlledMotor {
				pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
			}
		}

		sref TBLidar = Lidar {
			pose { x = 0.0 y = 0.0 z = 0.071 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}

		sref TBIMU = IMU {
			pose { x = 0.0 y = 0.0 z = 0.071 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}

		pose { x = 0.0 y = 0.0 z = 0.010 roll = 0.0 pitch = 0.0 yaw = 0.0 }
	}

	local link LeftWheel {
		def { }
		local body Wheel {
			def {
				inertial information {
					mass 0.02849894
					inertia matrix { ixx 0.0018158194 ixy -0.0000000000093392 ixz 0.0000000000104909 iyy 0.0032922126 iyz 0.0000000000575694 izz 0.0018158194 }
					pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				mesh {
					shape "meshes/wheels/left_tire.stl"
					scaling 0.001
				}
			}
			pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
		pose { x = 0.0 y = 0.08 z = 0.023 roll = 0.0 pitch = 0.0 yaw = 0.0 }
	}

	local link RightWheel {
		def { }
		local body Wheel {
			def {
				inertial information {
					mass 0.02849894
					inertia matrix { ixx 0.0018158194 ixy -0.0000000000093392 ixz 0.0000000000104909 iyy 0.0032922126 iyz 0.0000000000575694 izz 0.0018158194 }
					pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
				}
				mesh {
					shape "meshes/wheels/right_tire.stl"
					scaling 0.001
				}
			}
			pose { x = 0.0 y = 0.0 z = 0.0 roll = 0.0 pitch = 0.0 yaw = 0.0 }
		}
		pose { x = 0.0 y = -0.08 z = 0.023 roll = 0.0 pitch = 0.0 yaw = 0.0 }
	}
}

datatype LaserScan{
	angle_min: real
	angle_max: real
	angle_increment: real
	time_increment: real
	scan_time: real
	range_min: real
	range_max: real
	ranges: Seq(real)
	intensities: Seq(real)
}

sensor Lidar {
	const PI: real = 3.141592653589793
	const e: real = 2.718281828459045
	input trueDistance: real
	input measuredDistance: real
	input range_max: real
	input w_hit: real
	input w_short: real
	input w_max: real
	input w_rand: real
	input sigma_hit: real
	input lambda_short: real
	input angle_min: real
	output scan: LaserScan
	output measurement: real
	output closestDistance: real
	output closestAngle: real
	local p_hit: real
	local p_short: real
	local p_rand: real
	local p_max: real
	local eta1: real
	local eta2: real
	local N: real
	equation w_hit + w_short + w_max + w_rand == 1
	equation N == 1/(sqrt(2*PI*sigma_hit^2))*e^(-(0.5/sigma_hit^2)*(measuredDistance - trueDistance)^2)
	equation eta1 == (integral(N, 0, range_max))^-1
	equation eta2 == 1/(1- e^(-lambda_short*trueDistance))
	equation p_hit == ind(measuredDistance, 0, range_max)*eta1*N
	equation p_short == ind(measuredDistance, 0, trueDistance)*eta2*lambda_short*e^(-lambda_short*measuredDistance)
	equation p_max == ind(measuredDistance, range_max, range_max)
	equation p_rand == ind(measuredDistance, 0, range_max)*1/range_max
	equation measurement == w_hit*p_hit + w_short*p_short + w_max*p_max + w_rand*p_rand
	equation closestDistance == measuredDistance
	equation closestAngle == angle_min
	// Provide a minimal scan message that carries the measured distance as a single-beam range
	equation scan.angle_min == angle_min
	equation scan.angle_max == 0.0
	equation scan.angle_increment == 0.0
	equation scan.time_increment == 0.0
	equation scan.scan_time == 0.0
	equation scan.range_min == 0.0
	equation scan.range_max == range_max
	equation scan.ranges == <measuredDistance>
	equation scan.intensities == <0.0>
}

sensor IMU {
	input angularRateAV: real
	input angularRateLV: real
	output currentLV: real
	output currentAV: real
}


function ind(z_t: real, lower: real, upper: real): real {
	precondition lower <= upper
	postcondition result == if z_t >= lower /\ z_t <= upper then 1 else 0 end
}
