package circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.nio.file.Path;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtext.diagnostics.Severity;
import org.eclipse.xtext.resource.IResourceServiceProvider;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.eclipse.xtext.util.CancelIndicator;
import org.eclipse.xtext.validation.CheckMode;
import org.eclipse.xtext.validation.Issue;

import circus.robocalc.robosim.physmod.slnDF.SlnDFStandaloneSetup;
import circus.robocalc.robosim.physmod.slnRef.SlnRefStandaloneSetup;

/** Checks that an input model parses and validates before a test uses it. */
public final class InputCheck {

    private static final IResourceServiceProvider.Registry LANGUAGES = IResourceServiceProvider.Registry.INSTANCE;

    private static final Set<Path> VALID = ConcurrentHashMap.newKeySet();

    private InputCheck() {
    }

    /** Returns a solution reference ({@code .slnRef}) or solution ({@code .sln}) file after checking that it parses and validates. */
    public static Path valid(Path file) {
        Path model = file.toAbsolutePath().normalize();
        if (VALID.contains(model)) {
            return file;
        }
        URI uri = URI.createFileURI(model.toString());
        if (LANGUAGES.getResourceServiceProvider(uri) == null) {
            if (model.toString().endsWith(".slnRef")) {
                new SlnRefStandaloneSetup().createInjectorAndDoEMFRegistration();
            } else if (model.toString().endsWith(".sln")) {
                new SlnDFStandaloneSetup().createInjectorAndDoEMFRegistration();
            }
        }
        IResourceServiceProvider language = LANGUAGES.getResourceServiceProvider(uri);
        assertNotNull(language, "No language for " + model);
        valid(language.get(XtextResourceSet.class).getResource(uri, true));
        VALID.add(model);
        return file;
    }

    /** Fails unless an input model the test has already loaded has no parse or validation errors. */
    public static void valid(Resource resource) {
        assertTrue(resource.getErrors().isEmpty(), resource.getURI() + " does not parse: " + resource.getErrors());
        IResourceServiceProvider language = LANGUAGES.getResourceServiceProvider(resource.getURI());
        assertNotNull(language, "No language for " + resource.getURI());
        List<Issue> errors = language.getResourceValidator().validate(resource, CheckMode.ALL, CancelIndicator.NullImpl).stream()
            .filter(i -> i.getSeverity() == Severity.ERROR)
            .collect(Collectors.toList());
        assertTrue(errors.isEmpty(), resource.getURI() + " has " + errors.size() + " validation errors:\n" + errors.stream()
            .map(i -> "line " + i.getLineNumber() + ": " + i.getMessage())
            .collect(Collectors.joining("\n")));
    }
}
