package BaseModule
    function sin(theta:real): real {}
    function cos(theta:real): real {}
    
    
   
	pmodel Treel{
		local link Wheel {
			pose { x=0.0 y=-0.3 z=0.0 roll=1.57 pitch=0.0 yaw=0.0}
			def {}
			local body wheel {
				def {
					cylinder (radius=0.25, length=0.3)
				}
			}
		}
		local link Track {
			def{}
			local body FrontWheel {
				pose { x=-0.6 y=0.0 z=0.0 roll=1.57 pitch=0.0 yaw=0.0}
				def {
					cylinder (radius=0.25, length=0.3)
				}
			}
			local body BackWheel {
				pose { x=0.6 y=0.0 z=0.0 roll=1.57 pitch=0.0 yaw=0.0}
				def {
					cylinder (radius=0.25, length=0.3)
				}
			}
			local body Top {
				pose { x=0.0 y=0.0 z=0.25 roll=0.0 pitch=0.0 yaw=0.0}
				def {
					box (length=1.2, width=0.3, height=0.0)
				}
			}	 
		    local body Bottom {
				pose { x=0.0 y=0.0 z=-0.25 roll=0.0 pitch=0.0 yaw=0.0}
				def {
					box (length=1.2, width=0.3, height=0.0)
				}
			}
		}
} 
        
	pmodel BaseModule{
		const PI: real = 3.1415
		part LTREEL = Treel{
			pose { x=0.0 y=0.3 z=0.25 roll=3.14 pitch=0.0 yaw=0.0}
		}
		part RTREEL = Treel{
			pose { x=0.0 y=-0.3 z=0.25 roll=0.0 pitch=0.0 yaw=0.0}
		}
		local link Core {
			pose { x=0.0 y=0.0 z=0.575 roll=0.0 pitch=0.0 yaw=0.0}
			def {}
			local body Spine {
				pose { x=0.0 y=0.0 z=-0.225 roll=0.0 pitch=0.0 yaw=1.57}
				def {
					box (length=0.3, width=1.6, height=0.4) 
				}
			}
			local body Frame {
				def{
					cylinder (radius=0.85, length=0.05)
				}
			}										
			fixed to Track in LTREEL
			fixed to Track in RTREEL
			}
	}
	
	

	
