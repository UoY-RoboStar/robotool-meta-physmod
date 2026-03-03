package Testpart

import common::*

pmodel TESTP {
	const HEIGHT: real
	const WIDTH: real
	const DEPTH: real
	const h: int = 3
	const m: real = 4.0
	local link Wheel {
		pose { x=0.0 y=-DEPTH z=0.0 roll=PI/2 pitch=0.0 yaw=0.0 }
		def {
			inertial information {
				mass 0.0
				inertia matrix { ixx 0.0 ixy 0.0 ixz 0.0 iyy 0.0 iyz 0.0 izz 0.0 }
			}
		}
	}
	local link Track {
		pose { x=0.0 y=0.0 z=0.0 roll=0.0 pitch=0.0 yaw=0.0 }
		def {
			inertial information {
				mass 0.0
				inertia matrix { ixx 0.0 ixy 0.0 ixz 0.0 iyy 0.0 iyz 0.0 izz 0.0 }
			}
		}
		local body my_body {
			pose { x=PI y=HEIGHT z=0.9 roll=h pitch=m yaw=0.0 }
			def {
				sphere (radius=m)
			}
		}
		local sensor my_sonar_sensor {
			pose { x=0.0 y=0.0 z=0.9 roll=0.0 pitch=0.0 yaw=m }
			def {
				const p: int = 1
				const e: int = 3
				annotation Sonar {
					always_on = true update_rate=1.0
					sonar = SonarDetails {
						min = p+e
						max = m
						_radius = -DEPTH
					}
				}
			}
		}
	}
}
