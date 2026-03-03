annotation template MyTemplate1 {
    theta : real
    M : real
}

annotation template MyTemplate2 {
    theta : real  // Same name as in MyTemplate1
    M : real      // Same name as in MyTemplate1
}

pmodel AnnotationDuplicateTest {
    const n : int = 3

    local link BaseLink {
        def {}
    }
}
