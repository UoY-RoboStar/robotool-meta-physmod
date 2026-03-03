package testvar
import Testpart::*
import common::*

    function sin(theta:real): real {}
    function cos(theta:real): real {}
          
	pmodel testvar {
		const k: int
		const d: real
		part TEST = TESTP{
			instantiation HEIGHT = 0.05m
			instantiation DEPTH = 0.03m
			instantiation WIDTH = 0.17m
			pose { x=k y=-0.03 z=0.025 roll=0.0 pitch=0.0 yaw=d}
		}
		local link Core {
			def{}			
			local sensor my_sonar_sensor{
				pose {x=0.0 y=0.0 z=0.9 roll=0.0 pitch=0.0 yaw=0}
				def {
					const a: int
					const b: int =3
					annotation Sonar  {
						always_on = true update_rate=1.0
						sonar = SonarDetails {
							min = a
							max = b
							_radius =k
						}
					}
				}
			}											
			fixed to Track in TEST
			}
	}




