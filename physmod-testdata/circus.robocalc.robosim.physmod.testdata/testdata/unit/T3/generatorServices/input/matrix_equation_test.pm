pmodel MatrixEquationTest {
    // Model for testing matrix equation creation
    local phi: matrix(real,3,3)
    local I: matrix(real,3,3)
    
    // Test matrix equations
    local equation identity11: phi[1,1] = I[1,1]
    local equation identity12: phi[1,2] = 0
    local equation identity22: phi[2,2] = I[2,2]
}
