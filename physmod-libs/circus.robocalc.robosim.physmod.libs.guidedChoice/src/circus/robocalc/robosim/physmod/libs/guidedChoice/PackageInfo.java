package circus.robocalc.robosim.physmod.libs.guidedChoice;

/**
 * Marker class for PhysMod Guided Choice Libraries package.
 * This ensures the package exists for OSGi export.
 * 
 * Consumers should import classes from the sub-packages:
 * - circus.robocalc.robosim.physmod.libs.guidedChoice.solutionLib
 * - circus.robocalc.robosim.physmod.libs.guidedChoice.formulation
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
