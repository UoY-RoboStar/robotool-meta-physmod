import physmod::math::*

pmodel Pendulum {
	local link world {
		def {
		}
		local body world {
			def {
				inertial information {
					mass 0.01
					inertia matrix { ixx 0.01 ixy 0.0 ixz 0.0 iyy 0.0 iyz 0.0 izz 0.0 }
					pose {
						x = 0.0
						y = 0.0
						z = 0.0
						roll = 0.0
						pitch = 0.0
						yaw = 0.0
					}
				}
			}
			pose {
				x = 0.0
				y = 0.0
				z = 0.0
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
		}
	}

	local link base {
		def {
		}
		local body base {
			def {
				inertial information {
					mass 1.0
					inertia matrix { ixx 0.0 ixy 0.0 ixz 0.0 iyy 0.0 iyz 0.0 izz 0.0 }
					pose {
						x = 0.0
						y = 0.0
						z = 0.0
						roll = 0.0
						pitch = 0.0
						yaw = 0.0
					}
				}
				sphere ( radius = 0.015 )
			}
			pose {
				x = 0.0
				y = 0.0
				z = 0.0
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
		}
	}

	local link arm {
		def {
		}
		local body arm {
			def {
				inertial information {
					mass 0.5
					inertia matrix { ixx 0.0 ixy 0.0 ixz 0.0 iyy 0.0 iyz 0.0 izz 0.0 }
					pose {
						x = 0.0
						y = 0.0
						z = 0.0
						roll = 0.0
						pitch = 0.0
						yaw = 0.0
					}
				}
				cylinder ( radius = 0.01 , length = 0.75 )
			}
			pose {
				x = 0.0
				y = 0.0
				z = 0.0
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
		}
	}

	local link arm_com {
		def {
		}
		local body arm_com {
			def {
				inertial information {
					mass 0.5
					inertia matrix { ixx 0.0 ixy 0.0 ixz 0.0 iyy 0.0 iyz 0.0 izz 0.0 }
					pose {
						x = 0.0
						y = 0.0
						z = 0.0
						roll = 0.0
						pitch = 0.0
						yaw = 0.0
					}
				}
				sphere ( radius = 0.025 )
			}
			pose {
				x = 0.0
				y = 0.0
				z = 0.0
				roll = 0.0
				pitch = 0.0
				yaw = 0.0
			}
		}
	}

	local joint theta {
		def {
			const H : vector ( real , 6 ) = (| 0.00000 , 1.00000 , 0.00000 , 0 , 0 , 0 |)
		}
		flexibly connected to arm
	}

}
