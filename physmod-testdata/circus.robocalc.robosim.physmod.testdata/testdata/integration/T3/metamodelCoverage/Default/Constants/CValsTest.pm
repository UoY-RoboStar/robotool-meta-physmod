package CValsTest

import Constants::*

const A: real = 3.0
const B: real

pmodel CValsTest {
	const C: real = 2.0
	const D: real
	local link L1 {
		pose {
			x = A 
			y = B
			z = C
			roll = 0
			pitch = 0
			yaw = 0
		}
		def {
		}
		local body B1 {
			def {
				box(length = D, width = X, height = Y)
			}
		}
		local sensor MyIMU1 {
			def {
				const G: real = 8.0
				const H: real
				annotation IMU {
					update_rate = G
				}
			}
		}
		local sensor MyIMU2 {
			def {
				const G: real = 9.0
				const H: real
				annotation IMU { 
					update_rate = H
				}
			}
		}
		local sensor MyIMU3 {
			def {
				const G: real = 10.0
				const H: real

				annotation IMU {
					update_rate = B
				}
			}
		}
		local sensor MyIMU4 {
			def {
				const G: real = 11.0
				const H: real

				annotation IMU {
					update_rate = D
				}
			}
		}
		local sensor MyIMU5 {
			def {
				const G: real = 11.0
				const H: real

				annotation IMU {
					update_rate = H
				}
			}
		}
		jref j1 = J {
			instantiation J = 22
			flexibly connected to L2
		}
		jref j2 = J {
			instantiation J = 23
			flexibly connected to L2
		}
	}
	local link L2 {
		pose {
			x = A
			y = B
			z = C
			roll = 0
			pitch = 0
			yaw = 0
		}
		def {
		}
		local body B2 {
			def {
				box(length = D, width = X, height = Y)
			}
		}
	}
	part p1 = MyPart {
		instantiation F = 6.0
	}
	part p2 = MyPart {
		instantiation F = 7.0
	}
}
joint J {
	const I: real = 21
	const J: real
	annotation Revolute {
		axis = Axis {
			xyz = (|X,I,J|)
		}
	}
}
pmodel MyPart {
	const E: real = 5.0
	const F: real
	local link L1 {
		pose {
			x = A
			y = B
			z = E
			roll = 0
			pitch = 0
			yaw = 0
		}
		def {
		}
		local body B1 {
			def {
				box(length = F, width = X, height = Y)
			}
		}
	}
}
