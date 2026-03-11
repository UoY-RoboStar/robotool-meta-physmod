// ===============================================
// package physmod::trivial::sensors (Trivial sensors for trivial formulation)
// ===============================================

package physmod::trivial::sensors

import physmod::math::*

sensor TrivialSensor {
  input SignalIn : real
  output MeasurementOut : real

  equation SignalIn == MeasurementOut
}

// JointEncoder sensor for measuring joint angle and velocity
// Used for rotary encoders on revolute joints
sensor JointEncoder {
  input ThetaIn : real
  input DThetaIn : real
  output AngleOut : real
  output VelocityOut : real

  equation AngleOut == ThetaIn
  equation VelocityOut == DThetaIn
}

datatype LaserScan {
  angle_min : real
  angle_max : real
  angle_increment : real
  time_increment : real
  scan_time : real
  range_min : real
  range_max : real
  ranges : Seq(real)
  intensities : Seq(real)
}

sensor Lidar {
  const PI : real = 3.141592653589793
  const e : real = 2.718281828459045
  input trueDistance : real
  input measuredDistance : real
  input range_max : real
  input w_hit : real
  input w_short : real
  input w_max : real
  input w_rand : real
  input sigma_hit : real
  input lambda_short : real
  output scan : LaserScan
  output measurement : real
  local p_hit : real
  local p_short : real
  local p_rand : real
  local p_max : real
  local eta1 : real
  local eta2 : real
  local N : real

  equation w_hit + w_short + w_max + w_rand == 1
  equation N == 1/(sqrt(2*PI*sigma_hit^2))*e^(-(0.5/sigma_hit^2)*(measuredDistance - trueDistance)^2)
  equation eta1 == (integral(N, 0, range_max))^-1
  equation eta2 == 1/(1- e^(-lambda_short*trueDistance))
  equation p_hit == ind(measuredDistance, 0, range_max)*eta1*N
  equation p_short == ind(measuredDistance, 0, trueDistance)*eta2*lambda_short*e^(-lambda_short*measuredDistance)
  equation p_max == ind(measuredDistance, range_max, range_max)
  equation p_rand == ind(measuredDistance, 0, range_max)*1/range_max
  equation measurement == w_hit*p_hit + w_short*p_short + w_max*p_max + w_rand*p_rand
  equation scan.angle_min == 0.0
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
  input angularRateAV : real
  input angularRateLV : real
  output currentLV : real
  output currentAV : real

  equation currentLV == angularRateLV
  equation currentAV == angularRateAV
}

function ind(z_t : real, lower : real, upper : real) : real {
  precondition lower <= upper
  postcondition result == if z_t >= lower /\ z_t <= upper then 1 else 0 end
}

endpackage
