pmodel ComplexExpressionTest {
    // Model for testing complex expression parsing
    local phi: matrix(real,6,6)
    local B_k: matrix(real,4,4)
    local theta: real
    local L: real
    local sin: real -> real
    local cos: real -> real
    
    // Complex expressions that would require sophisticated parsing
    local equation complex1: phi[2,1] = sin(theta) * L
    local equation complex2: phi[3,1] = cos(theta) * B_k[1,1]
    local equation complex3: phi[4,2] = B_k[2,1] + B_k[2,2]
}
