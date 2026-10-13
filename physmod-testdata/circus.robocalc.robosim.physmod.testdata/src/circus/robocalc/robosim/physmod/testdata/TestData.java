package circus.robocalc.robosim.physmod.testdata;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

/**
 * Shared access to the generator test data and the comparison rule for expected files.
 *
 * Paths are relative to {@code physmod-testdata/circus.robocalc.robosim.physmod.testdata/testdata/},
 * for example {@code "integration/T3/SKO/expected/SimpleArmSerial.pm"}. A missing file is an error.
 */
public final class TestData {

    /** Path of the test data directory from the repository root. */
    private static final Path RELATIVE_ROOT =
        Paths.get("physmod-testdata", "circus.robocalc.robosim.physmod.testdata", "testdata");

    private static Path root;

    private TestData() {
    }

    /**
     * The {@code physmod-testdata/circus.robocalc.robosim.physmod.testdata/testdata/} directory,
     * found by searching upwards from the working directory, then from the location of this class.
     */
    public static synchronized Path root() {
        if (root == null) {
            List<Path> starts = new ArrayList<>();
            // Command-line (Maven) runs: the working directory is the tests project, inside the repository
            starts.add(Paths.get("").toAbsolutePath());
            // IDE runs: the working directory may be outside the repository, but this class is loaded
            // from the test data project's build output inside it
            try {
                starts.add(Paths.get(TestData.class.getProtectionDomain().getCodeSource().getLocation().toURI()));
            } catch (Exception e) {
                // the class location is not a file path in this runtime; the working directory is still searched
            }
            for (Path start : starts) {
                for (Path dir = start; dir != null; dir = dir.getParent()) {
                    if (Files.isDirectory(dir.resolve(RELATIVE_ROOT))) {
                        root = dir.resolve(RELATIVE_ROOT).normalize();
                        return root;
                    }
                }
            }
            throw new IllegalStateException("Test data directory " + RELATIVE_ROOT + " not found above " + starts);
        }
        return root;
    }

    /** The path of an existing test data file or directory. */
    public static Path path(String relativePath) {
        Path path = root().resolve(relativePath).normalize();
        if (!Files.exists(path)) {
            throw new IllegalArgumentException("Test data not found: " + path);
        }
        return path;
    }

    /** The content of an existing test data file, read as UTF-8. */
    public static String read(String relativePath) {
        return read(path(relativePath));
    }

    /**
     * Fails the test if {@code actual} differs from the expected file in anything other than line endings,
     * which differ between Windows and Unix.
     */
    public static void assertMatchesExpected(String expectedRelativePath, String actual) {
        assertMatchesExpected(path(expectedRelativePath), actual);
    }

    /** Same as {@link #assertMatchesExpected(String, String)}, for a {@code Path} inside the test data directory. */
    public static void assertMatchesExpected(Path expectedFile, String actual) {
        Path expected = expectedFile.toAbsolutePath().normalize();
        if (!expected.startsWith(root())) {
            throw new IllegalArgumentException("Not a test data file: " + expected);
        }
        String expectedText = read(expected);
        String difference = firstDifference(expectedText, actual);
        if (difference == null) {
            return;
        }
        Path actualFile = Paths.get("target", "actual-output").resolve(root().relativize(expected)).toAbsolutePath();
        try {
            Files.createDirectories(actualFile.getParent());
            Files.write(actualFile, actual.getBytes(StandardCharsets.UTF_8));
        } catch (IOException e) {
            actualFile = null;
        }
        throw new AssertionError("Output does not match " + root().relativize(expected) + "\n" + difference
            + (actualFile == null ? "" : "\nActual output written to " + actualFile));
    }

    /** A description of the first difference between two texts, or null if they match. */
    static String firstDifference(String expected, String actual) {
        String[] e = normalise(expected).split("\n", -1);
        String[] a = normalise(actual).split("\n", -1);
        int n = Math.min(e.length, a.length);
        for (int i = 0; i < n; i++) {
            if (!e[i].equals(a[i])) {
                return "First difference at line " + (i + 1) + ":\n"
                    + "  expected: " + show(e[i]) + "\n"
                    + "  actual:   " + show(a[i]);
            }
        }
        if (e.length > n) {
            return "Actual output ends after line " + n + "; expected continues: " + show(e[n]);
        }
        if (a.length > n) {
            return "Actual output has extra lines from line " + (n + 1) + ": " + show(a[n]);
        }
        return null;
    }

    private static String normalise(String text) {
        return text.replace("\r\n", "\n").replace('\r', '\n').replaceAll("\n+$", "");
    }

    /** A line in quotes with tabs shown, so that whitespace differences are visible. */
    private static String show(String line) {
        return "\"" + line.replace("\t", "\\t") + "\"";
    }

    private static String read(Path path) {
        try {
            return new String(Files.readAllBytes(path), StandardCharsets.UTF_8);
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }
}
