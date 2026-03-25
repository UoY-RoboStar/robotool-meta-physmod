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
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.TimeUnit;

import org.eclipse.xtext.generator.InMemoryFileSystemAccess;
import org.eclipse.xtext.testing.InjectWith;
import org.eclipse.xtext.testing.extensions.InjectionExtension;
import org.eclipse.xtext.testing.util.ParseHelper;
import org.junit.jupiter.api.Disabled;
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
public class TestAcrobot_CGATrajectoryMatchesSKO {

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
    private static final double BK_TOL = 1e-6;
    private static final String CGA_TESTDATA_PROJECT_PATH =
        "../../physmod-testdata/circus.robocalc.robosim.physmod.testdata/testdata/integration/T5/Acrobot/CGA/standalone_visualisation";

    @Disabled("Requires pipeline output / CMake / missing testdata")
    @Test
    public void testCgaTrajectoryMatchesSko() throws Exception {
        Path skoSlnRefPath = resolveSkoPipelineSlnRef();
        assertTrue(Files.exists(skoSlnRefPath), "Missing SKO pipeline slnRef: " + skoSlnRefPath);

        Path cgaSlnRefPath = cgaStandaloneRoot().resolve("input").resolve("acrobot_cga.slnRef");
        assertTrue(Files.exists(cgaSlnRefPath), "Missing CGA slnRef: " + cgaSlnRefPath);

        SlnRefs skoRefs = slnRefParseHelper.parse(Files.readString(skoSlnRefPath));
        assertNotNull(skoRefs, "Failed to parse SKO SlnRefs");
        assertTrue(skoRefs.eResource().getErrors().isEmpty(),
            "SKO slnRef parse errors: " + skoRefs.eResource().getErrors());
        stripNonDynamicsSolutions(skoRefs);

        SlnRefs cgaRefs = slnRefParseHelper.parse(Files.readString(cgaSlnRefPath));
        assertNotNull(cgaRefs, "Failed to parse CGA SlnRefs");
        assertTrue(cgaRefs.eResource().getErrors().isEmpty(),
            "CGA slnRef parse errors: " + cgaRefs.eResource().getErrors());
        stripNonDynamicsSolutions(cgaRefs);

        String oldMode = System.getProperty("physmod.generation.mode");
        try {
            System.setProperty("physmod.generation.mode", "STANDALONE");

            Path tempRoot = cgaStandaloneRoot().resolve("temp");
            deleteDirectory(tempRoot);
            Files.createDirectories(tempRoot);

            Trajectory skoTraj = generateAndRunStandalone(
                skoRefs,
                tempRoot.resolve("sko"),
                "theta",
                "d_theta"
            );
            Trajectory cgaTraj = generateAndRunStandalone(
                cgaRefs,
                tempRoot.resolve("cga"),
                "theta",
                "d_theta"
            );

            assertTrue(skoTraj.times.size() > 5, "SKO trajectory too short: " + skoTraj.times.size());
            assertTrue(cgaTraj.times.size() > 5, "CGA trajectory too short: " + cgaTraj.times.size());

            int n = Math.min(skoTraj.times.size(), cgaTraj.times.size());

            double maxTimeErr = 0.0;
            for (int i = 0; i < n; i++) {
                maxTimeErr = Math.max(maxTimeErr, Math.abs(skoTraj.times.get(i) - cgaTraj.times.get(i)));
            }
            assertTrue(maxTimeErr <= TIME_TOL, "Time columns differ (max |Delta t|=" + maxTimeErr + ")");

            Path trajDiff = tempRoot.resolve("cga").resolve("trajectory_diff.csv");
            writeTrajectoryDiff(trajDiff, cgaTraj, skoTraj, n);

            double maxErrIdentity = maxTrajError(skoTraj, cgaTraj, n, false);
            double maxErrSwap = maxTrajError(skoTraj, cgaTraj, n, true);
            double best = Math.min(maxErrIdentity, maxErrSwap);

            Path skoBk = tempRoot.resolve("sko").resolve("bk_t0.csv");
            Path cgaBk = tempRoot.resolve("cga").resolve("bk_t0.csv");
            assertTrue(Files.exists(skoBk), "Missing SKO B_k snapshot: " + skoBk);
            assertTrue(Files.exists(cgaBk), "Missing CGA B_k snapshot: " + cgaBk);

            Map<String, double[][]> skoBkMap = loadBkSnapshot(skoBk);
            Map<String, double[][]> cgaBkMap = loadBkSnapshot(cgaBk);

            Path bkDiff = tempRoot.resolve("cga").resolve("bk_diff.csv");
            writeBkDiff(bkDiff, skoBkMap, cgaBkMap);

            double maxBkIdentity = maxBkError(skoBkMap, cgaBkMap, false);
            double maxBkSwap = maxBkError(skoBkMap, cgaBkMap, true);
            double bestBk = Math.min(maxBkIdentity, maxBkSwap);

            assertTrue(
                bestBk <= BK_TOL,
                "B_k mismatch at t=0 (best max |Delta|=" + bestBk +
                    ", identity=" + maxBkIdentity + ", swap=" + maxBkSwap +
                    ", tol=" + BK_TOL + "). Diff saved to: " + bkDiff
            );

            assertTrue(
                best <= TRAJ_TOL,
                "CGA trajectory does not match SKO (best max |Delta|=" + best +
                    ", identity=" + maxErrIdentity + ", swap=" + maxErrSwap +
                    ", tol=" + TRAJ_TOL + "). Diff saved to: " + trajDiff
            );
        } finally {
            restoreProperty("physmod.generation.mode", oldMode);
        }
    }

    private static double maxTrajError(Trajectory sko, Trajectory cga, int n, boolean swapJoints) {
        double maxErr = 0.0;
        for (int i = 0; i < n; i++) {
            double sko_q0 = sko.q0.get(i);
            double sko_q1 = sko.q1.get(i);
            double sko_dq0 = sko.dq0.get(i);
            double sko_dq1 = sko.dq1.get(i);

            double cga_q0 = swapJoints ? cga.q1.get(i) : cga.q0.get(i);
            double cga_q1 = swapJoints ? cga.q0.get(i) : cga.q1.get(i);
            double cga_dq0 = swapJoints ? cga.dq1.get(i) : cga.dq0.get(i);
            double cga_dq1 = swapJoints ? cga.dq0.get(i) : cga.dq1.get(i);

            maxErr = Math.max(maxErr, Math.abs(sko_q0 - cga_q0));
            maxErr = Math.max(maxErr, Math.abs(sko_q1 - cga_q1));
            maxErr = Math.max(maxErr, Math.abs(sko_dq0 - cga_dq0));
            maxErr = Math.max(maxErr, Math.abs(sko_dq1 - cga_dq1));
        }
        return maxErr;
    }

    private static double maxBkError(Map<String, double[][]> sko, Map<String, double[][]> cga, boolean swap) {
        String[][] mapping = new String[][] {
            { "B_1", swap ? "B_2" : "B_1" },
            { "B_2", swap ? "B_1" : "B_2" },
            { "B_3", "B_3" }
        };

        double maxErr = 0.0;
        for (String[] pair : mapping) {
            double[][] skoMat = sko.get(pair[0]);
            double[][] cgaMat = cga.get(pair[1]);
            assertNotNull(skoMat, "Missing SKO matrix: " + pair[0]);
            assertNotNull(cgaMat, "Missing CGA matrix: " + pair[1]);

            for (int r = 0; r < 4; r++) {
                for (int c = 0; c < 4; c++) {
                    maxErr = Math.max(maxErr, Math.abs(skoMat[r][c] - cgaMat[r][c]));
                }
            }
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

        String engineCode = patchInvalidBkInit(patchEngineState(findGenerated(files, "platform1_engine.cpp")));
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
        Files.deleteIfExists(outDir.resolve("bk_t0.csv"));
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

    private static String patchInvalidBkInit(String engineCode) {
        if (engineCode == null) {
            return null;
        }
        String badInit = "B_k = std::vector<int>({ null, null, null });";
        if (!engineCode.contains(badInit)) {
            return engineCode;
        }
        String goodInit = "B_k = std::vector<Eigen::MatrixXd>(3, Eigen::MatrixXd::Identity(4, 4));";
        return engineCode.replace(badInit, goodInit);
    }

    private static String patchOrchestrator(String code, String posVar, String velVar) {
        String patched = code;

        if (!patched.contains("#include <iomanip>")) {
            patched = patched.replaceFirst("#include <fstream>\\s*", "#include <fstream>\n#include <iomanip>\n");
        }

        patched = patched.replaceAll("double\\s+max_time\\s*=\\s*[^;]+;", "double max_time = " + MAX_TIME_SECONDS + ";");
        patched = patched.replaceAll("usleep\\s*\\(\\s*sleep_us\\s*\\)\\s*;", "/* usleep disabled for tests */");

        String initMarker = "platform1_initialise();";
        String initWithLog =
            initMarker + "\n\n" +
            "    bool bk_written = false;\n\n" +
            "    std::ofstream traj(\"trajectory.csv\");\n" +
            "    traj << \"time,q0,q1,dq0,dq1\" << std::endl;\n" +
            "    traj << std::fixed << std::setprecision(9);\n";
        if (patched.contains(initMarker) && !patched.contains("trajectory.csv") && !patched.contains("bk_t0.csv")) {
            patched = patched.replace(initMarker, initWithLog);
        }

        String stepMarker = "platform1_step();";
        String stepWithLog =
            stepMarker + "\n" +
            "        if (!bk_written) {\n" +
            "            std::ofstream bk(\"bk_t0.csv\");\n" +
            "            if (bk.is_open()) {\n" +
            "                bk << std::fixed << std::setprecision(9);\n" +
            "                bk << \"name\";\n" +
            "                for (int r = 0; r < 4; ++r) {\n" +
            "                    for (int c = 0; c < 4; ++c) {\n" +
            "                        bk << \",m\" << r << c;\n" +
            "                    }\n" +
            "                }\n" +
            "                bk << std::endl;\n\n" +
            "                auto writeMatIdx = [&](const char* name, int idx) {\n" +
            "                    if (idx < 0 || static_cast<size_t>(idx) >= platform1::state.B_k.size()) {\n" +
            "                        return;\n" +
            "                    }\n" +
            "                    const Eigen::MatrixXd& M = platform1::state.B_k[idx];\n" +
            "                    bk << name;\n" +
            "                    for (int r = 0; r < 4; ++r) {\n" +
            "                        for (int c = 0; c < 4; ++c) {\n" +
            "                            bk << \",\" << M(r, c);\n" +
            "                        }\n" +
            "                    }\n" +
            "                    bk << std::endl;\n" +
            "                };\n\n" +
            "                writeMatIdx(\"B_1\", 0);\n" +
            "                writeMatIdx(\"B_2\", 1);\n" +
            "                writeMatIdx(\"B_3\", 2);\n" +
            "            }\n" +
            "            bk_written = true;\n" +
            "        }\n" +
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

    private static Path cgaStandaloneRoot() {
        return Paths.get("").toAbsolutePath().resolve(CGA_TESTDATA_PROJECT_PATH);
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

    private static void writeTrajectoryDiff(Path diffFile, Trajectory cga, Trajectory sko, int count) throws IOException {
        List<String> lines = new ArrayList<>();
        lines.add(String.join(",",
            "time",
            "c_q0", "c_q1", "c_dq0", "c_dq1",
            "s_q0_raw", "s_q1_raw", "s_dq0_raw", "s_dq1_raw",
            "s_q0_swap", "s_q1_swap", "s_dq0_swap", "s_dq1_swap",
            "dc_q0_raw", "dc_q1_raw", "dc_dq0_raw", "dc_dq1_raw",
            "dc_q0_swap", "dc_q1_swap", "dc_dq0_swap", "dc_dq1_swap"
        ));

        for (int i = 0; i < count; i++) {
            double cQ0 = cga.q0.get(i);
            double cQ1 = cga.q1.get(i);
            double cDq0 = cga.dq0.get(i);
            double cDq1 = cga.dq1.get(i);

            double sQ0 = sko.q0.get(i);
            double sQ1 = sko.q1.get(i);
            double sDq0 = sko.dq0.get(i);
            double sDq1 = sko.dq1.get(i);

            double sQ0Swap = sQ1;
            double sQ1Swap = sQ0;
            double sDq0Swap = sDq1;
            double sDq1Swap = sDq0;

            double dcQ0 = cQ0 - sQ0;
            double dcQ1 = cQ1 - sQ1;
            double dcDq0 = cDq0 - sDq0;
            double dcDq1 = cDq1 - sDq1;

            double dcQ0Swap = cQ0 - sQ0Swap;
            double dcQ1Swap = cQ1 - sQ1Swap;
            double dcDq0Swap = cDq0 - sDq0Swap;
            double dcDq1Swap = cDq1 - sDq1Swap;

            lines.add(String.format(Locale.ROOT,
                "%.6f,%.6f,%.6f,%.6f,%.6f," +
                "%.6f,%.6f,%.6f,%.6f," +
                "%.6f,%.6f,%.6f,%.6f," +
                "%.6f,%.6f,%.6f,%.6f," +
                "%.6f,%.6f,%.6f,%.6f",
                cga.times.get(i),
                cQ0, cQ1, cDq0, cDq1,
                sQ0, sQ1, sDq0, sDq1,
                sQ0Swap, sQ1Swap, sDq0Swap, sDq1Swap,
                dcQ0, dcQ1, dcDq0, dcDq1,
                dcQ0Swap, dcQ1Swap, dcDq0Swap, dcDq1Swap
            ));
        }

        Files.write(diffFile, lines, StandardCharsets.UTF_8);
    }

    private static Map<String, double[][]> loadBkSnapshot(Path csv) throws IOException {
        List<String> lines = Files.readAllLines(csv, StandardCharsets.UTF_8);
        assertTrue(lines.size() >= 2, "B_k CSV is empty: " + csv);

        Map<String, double[][]> mats = new HashMap<>();
        for (int i = 1; i < lines.size(); i++) {
            String line = lines.get(i).trim();
            if (line.isEmpty()) continue;
            String[] parts = line.split(",");
            assertTrue(parts.length >= 17, "Malformed B_k row: " + line);

            double[][] M = new double[4][4];
            int idx = 1;
            for (int r = 0; r < 4; r++) {
                for (int c = 0; c < 4; c++) {
                    M[r][c] = Double.parseDouble(parts[idx++]);
                }
            }
            mats.put(parts[0], M);
        }
        return mats;
    }

    private static void writeBkDiff(Path diffFile, Map<String, double[][]> sko, Map<String, double[][]> cga) throws IOException {
        List<String> lines = new ArrayList<>();
        lines.add("matrix,mapping,r,c,sko,cga,diff");

        writeBkDiff(lines, "identity", sko, cga, false);
        writeBkDiff(lines, "swap", sko, cga, true);

        Files.write(diffFile, lines, StandardCharsets.UTF_8);
    }

    private static void writeBkDiff(List<String> lines, String label, Map<String, double[][]> sko, Map<String, double[][]> cga, boolean swap) {
        String[][] mapping = new String[][] {
            { "B_1", swap ? "B_2" : "B_1" },
            { "B_2", swap ? "B_1" : "B_2" },
            { "B_3", "B_3" }
        };

        for (String[] pair : mapping) {
            double[][] skoMat = sko.get(pair[0]);
            double[][] cgaMat = cga.get(pair[1]);
            if (skoMat == null || cgaMat == null) continue;

            for (int r = 0; r < 4; r++) {
                for (int c = 0; c < 4; c++) {
                    double diff = cgaMat[r][c] - skoMat[r][c];
                    lines.add(String.format(Locale.ROOT,
                        "%s,%s,%d,%d,%.9f,%.9f,%.9f",
                        pair[0], label, r, c, skoMat[r][c], cgaMat[r][c], diff
                    ));
                }
            }
        }
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
