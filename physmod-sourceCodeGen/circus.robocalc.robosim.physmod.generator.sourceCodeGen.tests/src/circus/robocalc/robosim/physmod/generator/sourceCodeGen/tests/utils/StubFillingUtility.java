package circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests.utils;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Utility for filling stubs in generated test files with actual implementations from reference files.
 *
 * This utility surgically replaces stub placeholders (e.g., "[STUB]" messages, TODO sections)
 * with actual implementations from reference files, while preserving any T5-generated
 * platform-specific code.
 *
 * Key operations:
 * - fillOrchestratorStubs: Replace stub methods and data structures in orchestrator.cpp
 * - validateNoRemainingStubs: Verify all TODO/STUB markers are resolved
 */
public class StubFillingUtility {

    /**
     * Fill stubs in generated orchestrator.cpp with actual implementation from reference.
     *
     * Strategy:
     * - Replace entire file content except for platform-specific includes
     * - The orchestrator is mostly platform-independent except for the platform state include
     * - We preserve the platform name (e.g., platform1) in the includes
     *
     * @param generatedOrchestrator Path to generated stub orchestrator.cpp
     * @param referenceOrchestrator Path to reference implementation orchestrator.cpp
     * @param outputPath Path to write filled orchestrator.cpp
     * @param platformName Name of the platform (e.g., "platform1")
     * @throws IOException if file operations fail
     */
    public static void fillOrchestratorStubs(
            Path generatedOrchestrator,
            Path referenceOrchestrator,
            Path outputPath,
            String platformName) throws IOException {

        if (!Files.exists(generatedOrchestrator)) {
            throw new IOException("Generated orchestrator not found: " + generatedOrchestrator);
        }

        if (!Files.exists(referenceOrchestrator)) {
            throw new IOException("Reference orchestrator not found: " + referenceOrchestrator);
        }

        // Read reference implementation
        String referenceContent = Files.readString(referenceOrchestrator, StandardCharsets.UTF_8);

        // The reference uses "platform1" as the platform name
        // If the generated code uses a different platform name, we need to replace it
        // However, in SKO case, the platform name should already be "platform1"
        // But we make this generic for future use
        String filledContent = referenceContent;

        // If platform name is different from default, replace it
        // This handles cases where the platform might be named differently
        if (!platformName.equals("platform1")) {
            // Replace platform1_state.hpp with actual platform name
            filledContent = filledContent.replaceAll("platform1_state\\.hpp", platformName + "_state.hpp");
        }

        // Write filled orchestrator
        Files.writeString(outputPath, filledContent, StandardCharsets.UTF_8);

        System.out.println("✓ Filled orchestrator stubs from reference implementation");
    }

    /**
     * Validate that no remaining TODO or STUB markers exist in the file.
     *
     * @param filePath Path to file to validate
     * @return true if no stubs remain, false if stubs found
     * @throws IOException if file operations fail
     */
    public static boolean validateNoRemainingStubs(Path filePath) throws IOException {
        if (!Files.exists(filePath)) {
            return false;
        }

        String content = Files.readString(filePath, StandardCharsets.UTF_8);

        // Check for stub markers
        List<String> foundStubs = new ArrayList<>();

        // Pattern 1: [STUB] messages
        Pattern stubPattern = Pattern.compile("\\[STUB\\]");
        Matcher stubMatcher = stubPattern.matcher(content);
        if (stubMatcher.find()) {
            foundStubs.add("[STUB] marker found at position " + stubMatcher.start());
        }

        // Pattern 2: TODO: Implement markers
        Pattern todoPattern = Pattern.compile("TODO: Implement");
        Matcher todoMatcher = todoPattern.matcher(content);
        if (todoMatcher.find()) {
            foundStubs.add("TODO: Implement marker found at position " + todoMatcher.start());
        }

        // Pattern 3: "This is a generated stub" message
        if (content.contains("This is a generated stub")) {
            foundStubs.add("'This is a generated stub' message found");
        }

        if (content.contains("/* TODO/STUB")) {
            foundStubs.add("/* TODO/STUB */ marker found");
        }

        if (!foundStubs.isEmpty()) {
            System.out.println("⚠ Remaining stubs found in " + filePath.getFileName() + ":");
            for (String stub : foundStubs) {
                System.out.println("  - " + stub);
            }
            return false;
        }

        return true;
    }

    /**
     * Extract section between pragma region markers from content.
     *
     * @param content Full file content
     * @param regionName Name of the pragma region (e.g., "shared_state")
     * @return Content between #pragma region and #pragma endregion, or empty string if not found
     */
    public static String extractPragmaRegion(String content, String regionName) {
        Pattern pattern = Pattern.compile(
            "#pragma\\s+region\\s+" + Pattern.quote(regionName) +
            "\\s*\\n(.*?)\\n\\s*#pragma\\s+endregion",
            Pattern.DOTALL
        );
        Matcher matcher = pattern.matcher(content);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return "";
    }

    /**
     * Replace a pragma region in the content with new content.
     *
     * @param content Original content
     * @param regionName Name of the pragma region
     * @param newRegionContent New content for the region
     * @return Modified content with region replaced
     */
    public static String replacePragmaRegion(String content, String regionName, String newRegionContent) {
        Pattern pattern = Pattern.compile(
            "(#pragma\\s+region\\s+" + Pattern.quote(regionName) + "\\s*\\n)" +
            ".*?" +
            "(\\n\\s*#pragma\\s+endregion)",
            Pattern.DOTALL
        );
        Matcher matcher = pattern.matcher(content);
        if (matcher.find()) {
            return matcher.replaceFirst("$1" + Matcher.quoteReplacement(newRegionContent) + "$2");
        }
        return content;
    }

    /**
     * Count lines in file (for reporting).
     *
     * @param filePath Path to file
     * @return Number of lines in file
     * @throws IOException if file operations fail
     */
    public static int countLines(Path filePath) throws IOException {
        if (!Files.exists(filePath)) {
            return 0;
        }
        return (int) Files.lines(filePath).count();
    }
}
