package testActuatorVar

pmodel testActuatorVar {
	local link L {
		def {
		}
		local actuator my_light {
			def{
				const G : boolean = true
				annotation Light {
					cast_shadows=false
				}
			}
		}
	}
}