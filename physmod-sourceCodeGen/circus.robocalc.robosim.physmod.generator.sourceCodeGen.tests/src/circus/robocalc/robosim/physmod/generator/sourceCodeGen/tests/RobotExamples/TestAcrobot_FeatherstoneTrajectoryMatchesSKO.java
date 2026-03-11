package circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests.RobotExamples;

import static org.junit.jupiter.api.Assertions.*;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.TimeUnit;

import org.eclipse.xtext.generator.InMemoryFileSystemAccess;
import org.eclipse.xtext.testing.InjectWith;
import org.eclipse.xtext.testing.extensions.InjectionExtension;
import org.eclipse.xtext.testing.util.ParseHelper;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import com.google.inject.Inject;
import com.google.inject.Injector;

import circus.robocalc.robosim.physmod.generator.sourceCodeGen.MultiFileCppGenerator;
import circus.robocalc.robosim.physmod.generator.sourceCodeGen.SolutionRefGenerator;
import circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests.SlnDFInjectorProvider;
import circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests.SlnRefInjectorProvider;
import circus.robocalc.robosim.physmod.slnDF.slnDF.Solution;
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRef;
import circus.robocalc.robosim.physmod.slnRef.slnRef.SlnRefs;

@ExtendWith(InjectionExtension.class)
@InjectWith(SlnRefInjectorProvider.class)
public class TestAcrobot_FeatherstoneTrajectoryMatchesSKO {

    @Inject
    private ParseHelper<SlnRefs> slnRefParseHelper;

    private ParseHelper<Solution> solutionDSLParseHelper;

    private ParseHelper<Solution> getSolutionDSLParseHelper() {
        if (solutionDSLParseHelper == null) {
            SlnDFInjectorProvider provider = new SlnDFInjectorProvider();
            Injector injector = provider.getInjector();
            solutionDSLParseHelper = injector.getInstance(ParseHelper.class);
        }
        return solutionDSLParseHelper;
    }

    private static final double MAX_TIME_SECONDS = 2.0;
    private static final double TIME_TOL = 1e-9;
    private static final double TRAJ_TOL = 5e-3;

    @Test
    public void testFeatherstoneTrajectoryMatchesSKO() throws Exception {
        Path skoSlnRefPath = resolveSkoPipelineSlnRef();
        assertTrue(Files.exists(skoSlnRefPath), "Missing SKO pipeline slnRef: " + skoSlnRefPath);

        Path featherstoneSlnRefPath = Paths.get("tests", "integrationTests", "RobotExamples", "acrobot",
            "FEATHERSTONE", "standalone", "input", "acrobot_featherstone.slnRef").toAbsolutePath();
        assertTrue(Files.exists(featherstoneSlnRefPath), "Missing Featherstone slnRef: " + featherstoneSlnRefPath);

        SlnRefs skoRefs = slnRefParseHelper.parse(Files.readString(skoSlnRefPath));
        assertNotNull(skoRefs, "Failed to parse SKO SlnRefs");
        assertTrue(skoRefs.eResource().getErrors().isEmpty(),
            "SKO slnRef parse errors: " + skoRefs.eResource().getErrors());
        stripNonDynamicsSolutions(skoRefs);

        SlnRefs feRefs = slnRefParseHelper.parse(Files.readString(featherstoneSlnRefPath));
        assertNotNull(feRefs, "Failed to parse Featherstone SlnRefs");
        assertTrue(feRefs.eResource().getErrors().isEmpty(),
            "Featherstone slnRef parse errors: " + feRefs.eResource().getErrors());

        String oldMode = System.getProperty("physmod.generation.mode");
        try {
            System.setProperty("physmod.generation.mode", "STANDALONE");

            Path tempRoot = Paths.get("tests", "integrationTests", "RobotExamples", "acrobot",
                "FEATHERSTONE", "standalone", "temp").toAbsolutePath();
            deleteDirectory(tempRoot);
            Files.createDirectories(tempRoot);

            Trajectory skoTraj = generateAndRunStandalone(
                skoRefs,
                tempRoot.resolve("sko"),
                "theta",
                "d_theta"
            );
            Trajectory feTraj = generateAndRunStandalone(
                feRefs,
                tempRoot.resolve("featherstone"),
                "q",
                "d_q"
            );

            assertTrue(skoTraj.times.size() > 5, "SKO trajectory too short: " + skoTraj.times.size());
            assertTrue(feTraj.times.size() > 5, "Featherstone trajectory too short: " + feTraj.times.size());

            int n = Math.min(skoTraj.times.size(), feTraj.times.size());

            double maxTimeErr = 0.0;
            for (int i = 0; i < n; i++) {
                maxTimeErr = Math.max(maxTimeErr, Math.abs(skoTraj.times.get(i) - feTraj.times.get(i)));
            }
            assertTrue(maxTimeErr <= TIME_TOL, "Time columns differ (max |Δt|=" + maxTimeErr + ")");

            // Compare q/dq trajectories. Joint ordering can differ between formulations; accept best of identity or swap.
            double maxErrIdentity = maxTrajError(skoTraj, feTraj, n, false);
            double maxErrSwap = maxTrajError(skoTraj, feTraj, n, true);
            double best = Math.min(maxErrIdentity, maxErrSwap);

            assertTrue(
                best <= TRAJ_TOL,
                "Featherstone trajectory does not match SKO (best max |Δ|=" + best +
                    ", identity=" + maxErrIdentity + ", swap=" + maxErrSwap + ", tol=" + TRAJ_TOL + ")"
            );
        } finally {
            restoreProperty("physmod.generation.mode", oldMode);
        }
    }

    private static double maxTrajError(Trajectory sko, Trajectory fe, int n, boolean swapJoints) {
        double maxErr = 0.0;
        for (int i = 0; i < n; i++) {
            double sko_q0 = sko.q0.get(i);
            double sko_q1 = sko.q1.get(i);
            double sko_dq0 = sko.dq0.get(i);
            double sko_dq1 = sko.dq1.get(i);

            double fe_q0 = swapJoints ? fe.q1.get(i) : fe.q0.get(i);
            double fe_q1 = swapJoints ? fe.q0.get(i) : fe.q1.get(i);
            double fe_dq0 = swapJoints ? fe.dq1.get(i) : fe.dq0.get(i);
            double fe_dq1 = swapJoints ? fe.dq0.get(i) : fe.dq1.get(i);

            maxErr = Math.max(maxErr, Math.abs(sko_q0 - fe_q0));
            maxErr = Math.max(maxErr, Math.abs(sko_q1 - fe_q1));
            maxErr = Math.max(maxErr, Math.abs(sko_dq0 - fe_dq0));
            maxErr = Math.max(maxErr, Math.abs(sko_dq1 - fe_dq1));
        }
        return maxErr;
    }

    private Trajectory generateAndRunStandalone(SlnRefs slnRefs, Path outDir, String posVar, String velVar) throws Exception {
        Files.createDirectories(outDir);

        // STAGE 1: SlnRef -> Solution DSL
        SolutionRefGenerator gen = new SolutionRefGenerator();
        String solutionDSL = gen.compile(slnRefs);
        assertNotNull(solutionDSL, "Generated Solution DSL is null");
        assertFalse(solutionDSL.trim().isEmpty(), "Generated Solution DSL is empty");

        Solution solution = getSolutionDSLParseHelper().parse(solutionDSL);
        assertNotNull(solution, "Generated Solution DSL failed to parse");
        assertTrue(solution.eResource().getErrors().isEmpty(),
            "Solution DSL parse errors: " + solution.eResource().getErrors());

        // STAGE 2: Solution DSL -> C++
        MultiFileCppGenerator cppGen = new MultiFileCppGenerator();
        InMemoryFileSystemAccess fsa = new InMemoryFileSystemAccess();
        cppGen.doGenerate(solution.eResource(), fsa, null);

        Map<String, Object> files = fsa.getAllFiles();
        assertFalse(files.isEmpty(), "No files generated by T5");

        String engineCode = patchEngineState(findGenerated(files, "platform1_engine.cpp"));
        String stateCode = findGenerated(files, "platform1_state.hpp");
        String orchestratorCode = findGenerated(files, "orchestrator.cpp");

        assertNotNull(engineCode, "Missing platform1_engine.cpp in generated outputs");
        assertNotNull(stateCode, "Missing platform1_state.hpp in generated outputs");
        assertNotNull(orchestratorCode, "Missing orchestrator.cpp in generated outputs");

        Path engineFile = outDir.resolve("platform1_engine.cpp");
        Path stateFile = outDir.resolve("platform1_state.hpp");
        Path orchestratorFile = outDir.resolve("orchestrator.cpp");

        Files.writeString(engineFile, engineCode, StandardCharsets.UTF_8);
        Files.writeString(stateFile, stateCode, StandardCharsets.UTF_8);
        Files.writeString(orchestratorFile, patchOrchestrator(orchestratorCode, posVar, velVar), StandardCharsets.UTF_8);

        assertTrue(compileStandalone(outDir), "Compilation failed (" + outDir + ")");

        Path trajectoryFile = outDir.resolve("trajectory.csv");
        Files.deleteIfExists(trajectoryFile);
        assertTrue(runStandalone(outDir), "Execution failed (" + outDir + ")");
        assertTrue(Files.exists(trajectoryFile), "Trajectory file not created: " + trajectoryFile);

        return Trajectory.load(trajectoryFile);
    }

    private static String findGenerated(Map<String, Object> files, String suffix) {
        for (Map.Entry<String, Object> e : files.entrySet()) {
            String name = e.getKey();
            if (name.endsWith(suffix)) {
                return e.getValue().toString();
            }
            if (name.endsWith("src/" + suffix) || name.contains("/" + suffix)) {
                if (name.endsWith(suffix)) {
                    return e.getValue().toString();
                }
            }
        }
        // Fallback: any key containing suffix
        for (Map.Entry<String, Object> e : files.entrySet()) {
            if (e.getKey().contains(suffix)) {
                return e.getValue().toString();
            }
        }
        return null;
    }

    private static String patchEngineState(String engineCode) {
        if (engineCode == null) {
            return null;
        }
        String marker = "static platform1::State state;";
        if (!engineCode.contains(marker)) {
            return engineCode;
        }
        String replacement = String.join("\n",
            "namespace platform1 {",
            "    State state;",
            "}",
            "using platform1::state;"
        );
        return engineCode.replace(marker, replacement);
    }

    private static String patchOrchestrator(String code, String posVar, String velVar) {
        String patched = code;

        // Ensure we can format CSV
        if (!patched.contains("#include <iomanip>")) {
            patched = patched.replaceFirst("#include <fstream>\\s*", "#include <fstream>\n#include <iomanip>\n");
        }

        // Cap runtime for tests (and avoid real-time sleep)
        patched = patched.replaceAll("double\\s+max_time\\s*=\\s*[^;]+;", "double max_time = " + MAX_TIME_SECONDS + ";");
        patched = patched.replaceAll("usleep\\s*\\(\\s*sleep_us\\s*\\)\\s*;", "/* usleep disabled for tests */");

        // Add CSV logging immediately after platform initialisation
        String initMarker = "platform1_initialise();";
        String initWithLog =
            initMarker + "\n\n" +
            "    std::ofstream traj(\"trajectory.csv\");\n" +
            "    traj << \"time,q0,q1,dq0,dq1\" << std::endl;\n" +
            "    traj << std::fixed << std::setprecision(9);\n";
        if (patched.contains(initMarker) && !patched.contains("std::ofstream traj(\"trajectory.csv\")")) {
            patched = patched.replace(initMarker, initWithLog);
        }

        // Log after each platform step (use engine time for alignment)
        String stepMarker = "platform1_step();";
        String stepWithLog =
            stepMarker + "\n" +
            "        traj << platform1_get_time()"
            + " << \",\" << platform1::state." + posVar + "(0)"
            + " << \",\" << platform1::state." + posVar + "(1)"
            + " << \",\" << platform1::state." + velVar + "(0)"
            + " << \",\" << platform1::state." + velVar + "(1)"
            + " << std::endl;\n";
        if (patched.contains(stepMarker) && !patched.contains("traj << platform1_get_time()")) {
            patched = patched.replace(stepMarker, stepWithLog);
        }

        return patched;
    }

    private static boolean compileStandalone(Path outDir) {
        try {
            String eigenPath = System.getenv("EIGEN3_INCLUDE_DIR");
            if (eigenPath == null || eigenPath.isEmpty()) {
                eigenPath = "/usr/include/eigen3";
            }

            ProcessBuilder pb = new ProcessBuilder(
                "g++",
                "-O2",
                "-std=c++17",
                "-I" + eigenPath,
                "platform1_engine.cpp",
                "orchestrator.cpp",
                "-o", "physics_test"
            );
            pb.directory(outDir.toFile());
            pb.redirectErrorStream(true);

            Process process = pb.start();
            String output = readAll(process);
            boolean finished = process.waitFor(60, TimeUnit.SECONDS);
            if (!finished) {
                process.destroyForcibly();
                System.err.println("Compilation timed out");
                return false;
            }
            if (process.exitValue() != 0) {
                System.err.println("Compilation failed:\n" + output);
                return false;
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private static boolean runStandalone(Path outDir) {
        try {
            ProcessBuilder pb = new ProcessBuilder("./physics_test");
            pb.directory(outDir.toFile());
            pb.redirectErrorStream(true);

            Process process = pb.start();
            String output = readAll(process);

            boolean finished = process.waitFor(30, TimeUnit.SECONDS);
            if (!finished) {
                process.destroyForcibly();
                System.err.println("Execution timed out\n" + output);
                return false;
            }
            if (process.exitValue() != 0) {
                System.err.println("Execution failed:\n" + output);
                return false;
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private static String readAll(Process process) throws IOException {
        StringBuilder output = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                output.append(line).append("\n");
            }
        }
        return output.toString();
    }

    private static void stripNonDynamicsSolutions(SlnRefs refs) {
        if (refs == null || refs.getSolutionRefs() == null) return;
        Set<String> exclude = Set.of(
            "Visual",
            "Visualisation",
            "GeomExtraction",
            "PlatformMapping",
            "WorldMapping",
            "SensorOutputMapping",
            "MappingPM_Operation",
            "MappingPM_InputEvent",
            "ControlledActuator"
        );

        List<SlnRef> toRemove = new ArrayList<>();
        for (SlnRef r : refs.getSolutionRefs()) {
            String base = baseMethod(r.getMethod());
            if (exclude.contains(base)) {
                toRemove.add(r);
            }
        }
        refs.getSolutionRefs().removeAll(toRemove);
    }

    private static String baseMethod(String method) {
        if (method == null) return "";
        int idx = method.lastIndexOf("::");
        return idx >= 0 ? method.substring(idx + 2) : method;
    }

    private static Path resolveSkoPipelineSlnRef() throws IOException {
        Path rel = Paths.get(
            "physmod-testdata",
            "circus.robocalc.robosim.physmod.testdata",
            "testdata",
            "integration",
            "pipeline",
            "RobotExamples",
            "acrobot",
            "temp",
            "T4",
            "guidedChoice_GENERATORAcrobot.slnRef"
        );

        Path cwd = Paths.get("").toAbsolutePath();
        List<Path> candidates = List.of(
            cwd.resolve(rel),
            cwd.resolve("..").resolve(rel),
            cwd.resolve("..").resolve("..").resolve(rel)
        );
        for (Path p : candidates) {
            if (Files.exists(p)) return p.normalize();
        }
        throw new IOException("SKO pipeline slnRef not found. Tried: " + candidates);
    }

    private static void restoreProperty(String key, String value) {
        if (value != null) {
            System.setProperty(key, value);
        } else {
            System.clearProperty(key);
        }
    }

    private static void deleteDirectory(Path dir) throws IOException {
        if (!Files.exists(dir)) return;
        Files.walk(dir)
            .sorted((a, b) -> b.compareTo(a))
            .forEach(path -> {
                try {
                    Files.delete(path);
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
            });
    }

    private static final class Trajectory {
        final List<Double> times = new ArrayList<>();
        final List<Double> q0 = new ArrayList<>();
        final List<Double> q1 = new ArrayList<>();
        final List<Double> dq0 = new ArrayList<>();
        final List<Double> dq1 = new ArrayList<>();

        static Trajectory load(Path csv) throws IOException {
            List<String> lines = Files.readAllLines(csv, StandardCharsets.UTF_8);
            assertTrue(lines.size() >= 2, "Trajectory CSV is empty: " + csv);

            Trajectory t = new Trajectory();
            for (int i = 1; i < lines.size(); i++) {
                String line = lines.get(i).trim();
                if (line.isEmpty()) continue;
                String[] parts = line.split(",");
                if (parts.length < 5) continue;
                t.times.add(Double.parseDouble(parts[0]));
                t.q0.add(Double.parseDouble(parts[1]));
                t.q1.add(Double.parseDouble(parts[2]));
                t.dq0.add(Double.parseDouble(parts[3]));
                t.dq1.add(Double.parseDouble(parts[4]));
            }
            return t;
        }
    }
}
