
// Acrobot Spong Swing-up + LQR Controller (RoboSim textual / .rst)
//
// Implements the Spong swing-up controller as described in:
//   Spong, Mark W. "Swing up control of the acrobot." 1994.
//
// DESIGN NOTE: Uses a single combined sensor event to avoid codegen issues
// with multiple input events per cycle.

datatype AcrobotSensorState {
	shoulderAngle : real
	shoulderVelocity : real
	elbowAngle : real
	elbowVelocity : real
}

interface AcrobotSensorI {
	event sensorUpdate : AcrobotSensorState
}

interface AcrobotActuatorI {
	ApplyTorque ( tau : real )
}

controller AcrobotController {
	requires AcrobotActuatorI
	uses AcrobotSensorI
	sref stm_ref0 = AcrobotSwingUpLQR

	connection AcrobotController on sensorUpdate to stm_ref0 on sensorUpdate
	cycleDef cycle == 1
}

stm AcrobotSwingUpLQR {
	clock C

	// ===== Sensor event payload variable =====
	var su : AcrobotSensorState

	// ===== Sensor values =====
	var shoulder_angle : real = 0.0, shoulder_velocity : real = 0.0, elbow_angle : real = 0.0, elbow_velocity : real = 0.0

	// ===== Physical parameters =====
	const PI : real = 3.141592653589793, TWO_PI : real = 6.283185307179586
	const g : real = 9.81
	const m1 : real = 1.0, m2 : real = 1.0
	const l1 : real = 1.0, l2 : real = 2.0
	const lc1 : real = 0.5, lc2 : real = 1.0
	const Ic1 : real = 0.083, Ic2 : real = 0.333

	// ===== controller gains =====
	const k_e : real = 5.0,k_p : real = 50.0, k_d : real = 5.0
	
	// ===== LQR gains (Drake linearization at upright) =====
	const K0 : real = -278.44, K1 : real = -112.29, K2 : real = -119.72, K3 : real = -56.83

	// ===== Switching threshold and S matrix (Drake LQR) =====
	const balancing_threshold : real = 1000.0
	// S matrix for weighted switching criterion (symmetric 4x4)
	const S00 : real = 16620.60660545, S01 : real = 7470.18734010, S02 : real = 7240.12368147, S03 : real = 3571.58116271, S11 : real = 3374.43640794, S12 : real = 3256.40272521, S13 : real = 1608.54161654, S22 : real = 3154.73036214, S23 : real = 1556.50607291, S33 : real = 768.33308414
	// ===== Torque limits =====
	const TAU_MAX : real = 20.0

	// ===== Computation variables =====
	var q1 : real = 0.0, q2 : real = 0.0, dq1 : real = 0.0, dq2 : real = 0.0

	// Mass matrix elements
	var cos_q2 : real = 0.0, sin_q2 : real = 0.0, M11 : real = 0.0, M12 : real = 0.0, M22 : real = 0.0, det : real = 0.0

	// Energy terms
	var KE : real = 0.0, PE : real = 0.0, E : real = 0.0, E_desired : real = 0.0, E_tilde : real = 0.0

	// Control terms
	var u_e : real = 0.0, u_p : real = 0.0, y : real = 0.0, cos_q1 : real = 0.0, sin_q1 : real = 0.0, cos_q1_q2 : real = 0.0, sin_q1_q2 : real = 0.0, C1 : real = 0.0, C2 : real = 0.0, a2 : real = 0.0, a3 : real = 0.0

	// LQR error
	var x_err0 : real = 0.0, x_err1 : real = 0.0, x_err2 : real = 0.0, x_err3 : real = 0.0

	// Switching cost
	var cost : real = 0.0

	// Control output
	var tau_raw : real = 0.0, tau : real = 0.0

	// Mode flag
	var near_upright : boolean = false

	// Wrapping helper
	var wrap_tmp : real = 0.0

	input context { uses AcrobotSensorI }
	output context { requires AcrobotActuatorI }
	cycleDef cycle == 1

	initial i0
	junction j_mode
	junction j_clamp

	state Wait { }

	// ===== Compute state: processes all sensor values =====
	state Compute {
		entry
			// Map sensor readings
			q1 = shoulder_angle ;
			q2 = elbow_angle ;
			dq1 = shoulder_velocity ;
			dq2 = elbow_velocity ;

			// Wrap q1 to [0, 2π] (matches Drake convention)
			wrap_tmp = q1 / TWO_PI ;
			wrap_tmp = wrap_tmp - floor(wrap_tmp) ;
			q1 = wrap_tmp * TWO_PI ;

			// Wrap q2 to [-π, π]
			wrap_tmp = (q2 + PI) / TWO_PI ;
			wrap_tmp = wrap_tmp - floor(wrap_tmp) ;
			q2 = wrap_tmp * TWO_PI - PI ;

			// Trig functions
			cos_q2 = cos(q2) ;
			sin_q2 = sin(q2) ;
			cos_q1 = cos(q1) ;
			sin_q1 = sin(q1) ;
			cos_q1_q2 = cos(q1 + q2) ;
			sin_q1_q2 = sin(q1 + q2) ;

			// Mass matrix elements
			M11 = Ic1 + Ic2 + m1*lc1*lc1 + m2*(l1*l1 + lc2*lc2 + 2.0*l1*lc2*cos_q2) ;
			M12 = Ic2 + m2*(lc2*lc2 + l1*lc2*cos_q2) ;
			M22 = Ic2 + m2*lc2*lc2 ;
			det = M11*M22 - M12*M12 ;

			// State error from upright (q1=π, q2=0)
			x_err0 = q1 - PI ;
			x_err1 = q2 ;
			x_err2 = dq1 ;
			x_err3 = dq2 ;

			// Drake weighted switching criterion: cost = x_err' * S * x_err
			cost = S00*x_err0*x_err0 + 2.0*S01*x_err0*x_err1 + 2.0*S02*x_err0*x_err2 + 2.0*S03*x_err0*x_err3
			     + S11*x_err1*x_err1 + 2.0*S12*x_err1*x_err2 + 2.0*S13*x_err1*x_err3
			     + S22*x_err2*x_err2 + 2.0*S23*x_err2*x_err3
			     + S33*x_err3*x_err3 ;
			near_upright = cost < balancing_threshold
	}

	// ===== Swing-up mode =====
	state SwingUp {
		entry
			// Kinetic energy
			KE = 0.5 * (M11*dq1*dq1 + 2.0*M12*dq1*dq2 + M22*dq2*dq2) ;

			// Potential energy
			PE = - m1*g*lc1*cos_q1 - m2*g*(l1*cos_q1 + lc2*cos_q1_q2) ;

			// Total energy
			E = PE + KE ;

			// Desired energy (at upright: q1=π, q2=0)
			E_desired = (m1*lc1 + m2*(l1 + lc2)) * g ;

			// Energy error
			E_tilde = E - E_desired ;

			// Energy shaping: u_e = -k_e * E_tilde * dq2
			u_e = - k_e * E_tilde * dq2 ;

			// Partial feedback linearization target
			y = - k_p * q2 - k_d * dq2 ;

			// Coriolis + gravity terms
			C1 = - m2*l1*lc2*sin_q2*(2.0*dq1*dq2 + dq2*dq2) + (m1*lc1 + m2*l1)*g*sin_q1 + m2*lc2*g*sin_q1_q2 ;
			C2 = m2*l1*lc2*sin_q2*(dq1*dq1) + m2*lc2*g*sin_q1_q2 ;

			// Inverse mass matrix elements
			a2 = - M12 / det ;
			a3 = M11 / det ;

			// Partial feedback linearization
			u_p = (a2 * C1 + y) / a3 + C2 ;

			// Combined swing-up control
			tau_raw = u_e + u_p
	}

	// ===== LQR balancing mode =====
	state Balance {
		entry
			tau_raw = -(K0 * x_err0 + K1 * x_err1 + K2 * x_err2 + K3 * x_err3)
	}

	// ===== Clamping states =====
	state ClampHigh {
		entry tau = TAU_MAX
	}

	state ClampLow {
		entry tau = - TAU_MAX 
	}

	state InRange {
		entry tau = tau_raw
	}

	// ===== Output state: single exec per cycle =====
	state Output {
		entry 
			// Output torque
			$ApplyTorque ( tau )
	}

	// ===== Transitions =====
	transition t_init {
		from i0
		to Wait
	}

	// Single transition to receive combined sensor event
	transition t_recv_sensors {
		from Wait
		to Compute
		condition $ sensorUpdate ? su
		action
			shoulder_angle = su.shoulderAngle ;
			shoulder_velocity = su.shoulderVelocity ;
			elbow_angle = su.elbowAngle ;
			elbow_velocity = su.elbowVelocity
	}

	// After Compute, go to mode junction
	transition t_to_mode {
		from Compute
		to j_mode
	}

	// Mode selection
	transition t_swing {
		from j_mode
		to SwingUp
		condition not near_upright 
	}

	transition t_balance {
		from j_mode
		to Balance
		condition near_upright
	}

	// After control computation, go to clamping
	transition t_swing_to_clamp {
		from SwingUp
		to j_clamp
	}

	transition t_balance_to_clamp {
		from Balance
		to j_clamp
	}

	// Clamping logic
	transition t_clamp_high {
		from j_clamp
		to ClampHigh
		condition tau_raw > TAU_MAX
	}

	transition t_clamp_low {
		from j_clamp
		to ClampLow
		condition tau_raw < - TAU_MAX
	}

	transition t_in_range {
		from j_clamp
		to InRange
		condition tau_raw >= - TAU_MAX /\ tau_raw <= TAU_MAX
	}

	// Output transitions
	transition t_high_to_output {
		from ClampHigh
		to Output
	} 

	transition t_low_to_output {
		from ClampLow
		to Output
	}

	transition t_range_to_output {
		from InRange
		to Output
	}

	// After output, back to Wait with exec (single cycle boundary)
	transition t_output_to_wait {
		from Output
		to Wait
		action exec
	}
}

module AcrobotSwingUpLQRModule {
	robotic platform AcrobotPlatform {
		uses AcrobotSensorI provides AcrobotActuatorI
	}

	cref ctrl_ref0 = AcrobotController
	cycleDef cycle == 1

	connection AcrobotPlatform on sensorUpdate to ctrl_ref0 on sensorUpdate ( _async )
}

function sin(x: real): real {}
function cos(x: real): real {}
function floor(x: real): real {}
