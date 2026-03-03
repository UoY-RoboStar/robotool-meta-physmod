package BodySphere
	import physmod::sdf::annotations::*
	function sin(theta:real): real {}
    function cos(theta:real): real {}
	const PI: real = 3.1415  
	pmodel BodySphere{
		local link Tip{
			def {}
			pose { x=0.0 y=0.0 z=0.9 roll=0.0 pitch=0.0 yaw=0.0}
			local body my_body {
				def {
					sphere  (radius=0.05)
				}
			}
		}	
	}