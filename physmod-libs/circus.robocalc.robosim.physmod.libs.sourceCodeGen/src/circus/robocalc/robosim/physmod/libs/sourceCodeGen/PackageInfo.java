package circus.robocalc.robosim.physmod.libs.sourceCodeGen;

/**
 * Marker class for PhysMod Source Code Generation Libraries package.
 * This ensures the package exists for OSGi export.
 * 
 * Consumers should import classes from the sub-packages:
 * - circus.robocalc.robosim.physmod.libs.sourceCodeGen.solutionLib
 * - circus.robocalc.robosim.physmod.libs.sourceCodeGen.formulation
 * - circus.robocalc.robosim.physmod.libs.sourceCodeGen.libUtils
 */
public final class PackageInfo {
    private PackageInfo() {
        // Utility class - no instances
    }
    
    /**
     * @return Version information for this library
     */
    public static String getVersion() {
        return "3.0.0";
    }
}
