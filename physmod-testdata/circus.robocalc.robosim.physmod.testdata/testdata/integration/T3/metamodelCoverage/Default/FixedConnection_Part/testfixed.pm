package testfixed
pmodel testfixed {
	part TLB=testlinkb{
		
	}
	part TLA=testlinka{
			link linkA fixed to linkB in TLB		
	}	
}

pmodel testlinka{	
	local link linkA {
		
						pose {x=1.0 y=0.5 z=0.5 roll=1.5708 pitch=3.14159 yaw=-1.0472}
		def {
		}
		local body bodyA {
			def {
				
											box (length=1.0, width=1.0, height=1.0)
			}
		}
	}
}
pmodel testlinkb{	
	local link linkB {
		
						pose { x=0.0 y=-0.5 z=0.5 roll=1.0472 pitch=-0.785398 yaw=1.0472}
		def {
			
								inertial information{ 
									mass 1.0
								}
		}
		local body bodyB {
			def {
				
											box (length=1.0, width=1.0, height=1.0)
			}
		}
	}	
}