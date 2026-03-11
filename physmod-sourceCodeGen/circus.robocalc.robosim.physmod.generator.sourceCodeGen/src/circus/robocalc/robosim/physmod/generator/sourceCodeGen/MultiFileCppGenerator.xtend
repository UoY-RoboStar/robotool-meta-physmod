/*
 * Copyright (c) 2026 University of York and others
 *
 * Multi-file C++ generator
 * Contributors:
 *   Arjun Badyal
 ********************************************************************************/

package circus.robocalc.robosim.physmod.generator.sourceCodeGen

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import circus.robocalc.robosim.physmod.slnDF.slnDF.Solution
import circus.robocalc.robosim.physmod.libs.sourceCodeGen.formulation.SKO

/**
 * C++ generator that creates platform_engine.cpp matching SimpleArmHeadless structure
 *
 * Generation Modes:
 * - STANDALONE: Minimal dependencies, simple C API, no orchestrator (for testing)
 * - STANDALONE_VISUALISATION: Standalone with visualisation support
 * - FULL_SIMULATION: Full orchestrator integration with interfaces.hpp (manual mapping setup)
 * - FULL_SIMULATION_VISUALISATION: Full simulation with visualisation support
 * - FULL_SIMULATION_MAPPING: Full simulation + auto-generated mapping from Mapping.pm
 *
 * Architecture:
 * - platform<N>_engine.cpp: Complete physics engine with state, procedures, functions, computation, API
 * - Template files: interfaces.hpp, utils.cpp/h, orchestrator.cpp (copied from templates/)
 * - State header: platform<N>_state.hpp (generated from Solution DSL state section)
 */
class MultiFileCppGenerator extends SolutionToCppGenerator {

    // Instance variable to store generation mode for use across methods
    private GenerationMode mode = null

    /**
     * Generation mode enumeration
     */
    enum GenerationMode {
        STANDALONE,           // Minimal dependencies, no orchestrator
        STANDALONE_VISUALISATION,    // Minimal orchestrator with visualisation, no d-model/world/mapping
        FULL_SIMULATION,      // Full Simulation: With orchestrator, manual mapping setup
        FULL_SIMULATION_VISUALISATION,  // Full Simulation with Visualisation: With orchestrator + visualisation support
        FULL_SIMULATION_MAPPING    // Full Simulation with Mapping: With orchestrator + auto-generated mapping from Mapping.pm
    }

    /**
     * Determine generation mode from solution metadata or configuration
     *
     * Precedence (highest to lowest):
     * 1. System property: -Dphysmod.generation.mode=STANDALONE|STANDALONE_VISUALISATION|FULL_SIMULATION|FULL_SIMULATION_VISUALISATION|FULL_SIMULATION_MAPPING (INTEGRATED/INTEGRATED_MAPPING/VISUAL variants also accepted for backward compatibility)
     * 2. Automatic detection: STANDALONE + visualisation enabled -> STANDALONE_VISUALISATION, FULL_SIMULATION + visualisation enabled -> FULL_SIMULATION_VISUALISATION
     * 3. Solution name pattern: *_standalone -> STANDALONE, *_full_simulation -> FULL_SIMULATION
     * 4. Default: FULL_SIMULATION (backward compatibility)
     */
    def GenerationMode getGenerationMode(Solution solution) {
        // Step 1: Check system property (highest precedence)
        val modeFromProperty = getGenerationModeFromProperty()
        if (modeFromProperty !== null) {
            logModeSelection(modeFromProperty, "system property")
            return modeFromProperty
        }

        // Step 2: Check solution name patterns
        val modeFromName = getGenerationModeFromSolutionName(solution)
        if (modeFromName !== null) {
            // Apply visualization override for STANDALONE and FULL_SIMULATION modes
            val finalMode = applyVisualizationOverride(modeFromName, solution)
            logModeSelection(finalMode, "solution name")
            return finalMode
        }

        // Step 3: Default fallback
        val defaultMode = GenerationMode.FULL_SIMULATION
        logModeSelection(defaultMode, "default")
        return defaultMode
    }

    /**
     * Parse generation mode from system property
     */
    private def GenerationMode getGenerationModeFromProperty() {
        val sysProp = System.getProperty("physmod.generation.mode")
        if (sysProp === null || sysProp.isEmpty()) {
            return null
        }

        try {
            val upperProp = sysProp.toUpperCase()
            // Backward compatibility: accept old INTEGRATED names
            if (upperProp == "INTEGRATED") {
                return GenerationMode.FULL_SIMULATION
            }
            if (upperProp == "INTEGRATED_MAPPING") {
                return GenerationMode.FULL_SIMULATION_MAPPING
            }
            // Backward compatibility: accept old VISUAL names
            if (upperProp == "STANDALONE_VISUAL") {
                return GenerationMode.STANDALONE_VISUALISATION
            }
            if (upperProp == "FULL_SIMULATION_VISUAL") {
                return GenerationMode.FULL_SIMULATION_VISUALISATION
            }
            return GenerationMode.valueOf(upperProp)
        } catch (IllegalArgumentException e) {
            System.err.println("[T5 Generator] WARNING: Invalid generation mode: '" + sysProp +
                "'. Valid modes are: STANDALONE, STANDALONE_VISUALISATION, FULL_SIMULATION, FULL_SIMULATION_VISUALISATION, FULL_SIMULATION_MAPPING (INTEGRATED/INTEGRATED_MAPPING/VISUAL variants also accepted)")
            return null
        }
    }

    /**
     * Infer generation mode from solution name
     */
    private def GenerationMode getGenerationModeFromSolutionName(Solution solution) {
        val solutionName = solution?.name
        if (solutionName === null || solutionName.isEmpty()) {
            return null
        }

        val lowerName = solutionName.toLowerCase()

        // Check for explicit mode indicators in name
        if (lowerName.contains("full_simulation_mapping") || lowerName.contains("integrated_mapping")) {
            return GenerationMode.FULL_SIMULATION_MAPPING
        }
        if ((lowerName.contains("full_simulation_visual") || lowerName.contains("full_simulation_visualisation") || 
             lowerName.contains("integrated_visual") || lowerName.contains("integrated_visualisation")) && 
            (lowerName.contains("visual") || lowerName.contains("visualisation"))) {
            return GenerationMode.FULL_SIMULATION_VISUALISATION
        }
        if ((lowerName.contains("standalone_visual") || lowerName.contains("standalone_visualisation")) &&
            (lowerName.contains("visual") || lowerName.contains("visualisation"))) {
            return GenerationMode.STANDALONE_VISUALISATION
        }
        if (lowerName.contains("full_simulation") || lowerName.contains("integrated")) {
            return GenerationMode.FULL_SIMULATION
        }
        if (lowerName.contains("standalone")) {
            return GenerationMode.STANDALONE
        }

        return null
    }

    /**
     * Apply visualisation override: STANDALONE + visualisation -> STANDALONE_VISUALISATION,
     * FULL_SIMULATION + visualisation -> FULL_SIMULATION_VISUALISATION
     */
    private def GenerationMode applyVisualizationOverride(GenerationMode mode, Solution solution) {
        val visualizationEnabled = isVisualisationEnabled(solution)
        if (mode == GenerationMode.STANDALONE && visualizationEnabled) {
            return GenerationMode.STANDALONE_VISUALISATION
        }
        if (mode == GenerationMode.FULL_SIMULATION && visualizationEnabled) {
            return GenerationMode.FULL_SIMULATION_VISUALISATION
        }
        return mode
    }

    /**
     * Log the selected generation mode for debugging
     */
    private def void logModeSelection(GenerationMode mode, String source) {
        if (System.getProperty("physmod.debug") !== null) {
            System.out.println("[T5 Generator] Using generation mode: " + mode + " (from " + source + ")")
        }
    }

    /**
     * Validate mode and property combinations
     * Ensures that incompatible configurations are detected early
     */
    private def void validateModeConfiguration(GenerationMode mode, boolean visualizationEnabled) {
        val outputFormat = System.getProperty("physmod.output.format")

        // Only validate for C++ generation
        if (outputFormat !== null && !outputFormat.equalsIgnoreCase("CPP")) {
            // Non-C++ formats don't use generation modes
            if (mode != GenerationMode.FULL_SIMULATION) {
                System.err.println("[T5 Generator] WARNING: Generation mode '" + mode +
                    "' is only applicable for C++ output. Ignoring for " + outputFormat)
            }
            if (visualizationEnabled) {
                System.err.println("[T5 Generator] WARNING: Visualization is only supported for C++ output. " +
                    "Ignoring for " + outputFormat)
            }
            return
        }

        // Validate STANDALONE_VISUALISATION mode
        if (mode == GenerationMode.STANDALONE_VISUALISATION && !visualizationEnabled) {
            System.err.println("[T5 Generator] WARNING: STANDALONE_VISUALISATION mode requires visualisation to be enabled. " +
                "Enabling visualisation automatically.")
            System.setProperty("physmod.visualisation.enabled", "true")
        }

        // Validate FULL_SIMULATION_VISUALISATION mode
        if (mode == GenerationMode.FULL_SIMULATION_VISUALISATION && !visualizationEnabled) {
            System.err.println("[T5 Generator] WARNING: FULL_SIMULATION_VISUALISATION mode requires visualisation to be enabled. " +
                "Enabling visualisation automatically.")
            System.setProperty("physmod.visualisation.enabled", "true")
        }

        // Validate visualisation with STANDALONE mode
        if (mode == GenerationMode.STANDALONE && visualizationEnabled) {
            System.err.println("[T5 Generator] INFO: STANDALONE mode with visualisation enabled. " +
                "Consider using STANDALONE_VISUALISATION mode instead for better integration.")
        }

        // Validate visualisation with FULL_SIMULATION mode
        if (mode == GenerationMode.FULL_SIMULATION && visualizationEnabled) {
            System.err.println("[T5 Generator] INFO: FULL_SIMULATION mode with visualisation enabled. " +
                "Consider using FULL_SIMULATION_VISUALISATION mode instead for better integration.")
        }

        // Validate mapping modes
        if (mode == GenerationMode.FULL_SIMULATION_MAPPING) {
            val mappingFile = System.getProperty("physmod.mapping.file")
            if (mappingFile === null || mappingFile.isEmpty()) {
                System.err.println("[T5 Generator] INFO: FULL_SIMULATION_MAPPING mode selected but no mapping file specified. " +
                    "Auto-generation will use default mappings.")
            }
        }

        // Log current configuration if debug mode
        if (System.getProperty("physmod.debug") !== null) {
            System.out.println("[T5 Generator] Configuration validated:")
            System.out.println("  - Output format: " + (outputFormat ?: "CPP"))
            System.out.println("  - Generation mode: " + mode)
            System.out.println("  - Visualization: " + visualizationEnabled)
            System.out.println("  - Velocity logging: " + isVelocityLoggingEnabled(null))
        }
    }

    /**
     * Determine if velocity logging should be included in generated code
     * Controlled by system property: -Dphysmod.velocity.logging=true
     */
    def boolean isVelocityLoggingEnabled(Solution solution) {
        val sysProp = System.getProperty("physmod.velocity.logging")
        if (sysProp !== null && sysProp.equalsIgnoreCase("true")) {
            return true
        }
        return false
    }

    def boolean isTrajectoryLoggingEnabled(Solution solution) {
        val sysProp = System.getProperty("physmod.trajectory.logging")
        if (sysProp !== null && sysProp.equalsIgnoreCase("true")) {
            return true
        }
        return false
    }

    private def boolean hasStateVariable(Solution solution, String name) {
        if (solution?.state?.variables === null) {
            return false
        }
        return solution.state.variables.exists[v | v.variable?.name == name]
    }

    private def boolean hasClosedChainDiagnostics(Solution solution) {
        return hasStateVariable(solution, "g_pos") &&
               hasStateVariable(solution, "G_c") &&
               hasStateVariable(solution, "theta")
    }

    /**
     * Determine if visualization should be enabled
     *
     * Checks in order:
     * 1. System property: -Dphysmod.visualisation.enabled=true (from UI toggle or test)
     * 2. Solution name pattern: name contains "visual"
     *
     * @return true if visualization should be enabled
     */
    def boolean isVisualisationEnabled(Solution solution) {
        // Check system property first (from UI or programmatic configuration)
        val sysProp = System.getProperty("physmod.visualisation.enabled")
        if (sysProp !== null && sysProp.equalsIgnoreCase("true")) {
            return true
        }

        // Fallback to solution name pattern for backward compatibility
        val name = solution?.name
        return name !== null && name.toLowerCase.contains("visual")
    }

    /**
     * Generate complete C++ physics engine from Solution DSL
     */
    override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
        val solution = resource.allContents.filter(Solution).head
        if (solution === null) {
            return
        }

        val platformName = extractPlatformName(solution)
        this.mode = getGenerationMode(solution)
        var visualizationEnabled = isVisualisationEnabled(solution)

        // Validate mode and property combinations (may flip the system property)
        validateModeConfiguration(this.mode, visualizationEnabled)
        // Re-evaluate visualization flag in case validation toggled the property
        visualizationEnabled = isVisualisationEnabled(solution)

        // Fail-fast: visualisation requested but no Geom records available
        if (visualizationEnabled) {
            val geomRecordsForValidation = extractGeomRecords(solution)
            if (geomRecordsForValidation.isEmpty) {
                throw new IllegalStateException(
                    "[T5 Generator] Visualisation enabled but no Geom records were found. " +
                    "Add Geom records to the Solution (e.g., L1_geom) or disable visualisation.")
            }

            // NOTE:
            // Older solutions declared T_geom in state; newer visualisation code computes it dynamically as:
            //   T_geom_k = B_k * T_offset_k
            // Therefore T_geom is not required to be a state variable anymore.
            // We keep the Geom-record fail-fast check above (still required to know shapes).
        }

        // Determine output directory based on mode
        val isFullMode = this.mode == GenerationMode.FULL_SIMULATION || this.mode == GenerationMode.FULL_SIMULATION_VISUALISATION || this.mode == GenerationMode.FULL_SIMULATION_MAPPING
        val srcPrefix = if (isFullMode) "src/" else ""
        val visualAssetPrefix = if (isFullMode) "src/" else ""

        // Generate main platform engine file
        fsa.generateFile(srcPrefix + platformName + "_engine.cpp", generatePlatformEngine(solution, this.mode))

        // Generate state header
        fsa.generateFile(srcPrefix + platformName + "_state.hpp", generateStateHeader(solution, platformName, this.mode, visualizationEnabled))

        // Mode-specific generation
        switch (this.mode) {
            case STANDALONE: {
                // Generate minimal orchestrator for standalone physics simulation
                // Comments out d-model, world engine, and mapping parts
                fsa.generateFile(srcPrefix + "orchestrator.cpp", generateMinimalOrchestrator(solution, platformName, mode))
                // Generate CMakeLists.txt for standalone build
                fsa.generateFile("CMakeLists.txt", generateCMakeLists(solution, platformName, mode))
            }
            case STANDALONE_VISUALISATION: {
                // Generate minimal orchestrator with visualisation support
                // Generate world_mapping.h for gravity synchronization
                fsa.generateFile(srcPrefix + "world_mapping.h", generateWorldMappingHeader())
                fsa.generateFile(srcPrefix + "orchestrator.cpp", generateMinimalOrchestrator(solution, platformName, mode))
                // Generate CMakeLists.txt for standalone visualisation build
                fsa.generateFile("CMakeLists.txt", generateCMakeLists(solution, platformName, mode))
            }
            case FULL_SIMULATION: {
                // Generate orchestrator stub (user provides mapping manually)
                fsa.generateFile(srcPrefix + "orchestrator.h", generateOrchestratorHeader(solution, platformName, mode))
                fsa.generateFile(srcPrefix + "orchestrator.cpp", generateOrchestrator(solution, platformName, mode))
            }
            case FULL_SIMULATION_VISUALISATION: {
                // Generate orchestrator stub with visualization support (user provides mapping manually)
                fsa.generateFile(srcPrefix + "orchestrator.h", generateOrchestratorHeader(solution, platformName, mode))
                fsa.generateFile(srcPrefix + "orchestrator.cpp", generateOrchestrator(solution, platformName, mode))
            }
            case FULL_SIMULATION_MAPPING: {
                // Generate orchestrator + auto-generated mapping
                fsa.generateFile(srcPrefix + "orchestrator.h", generateOrchestratorHeader(solution, platformName, mode))
                fsa.generateFile(srcPrefix + "orchestrator.cpp", generateOrchestrator(solution, platformName, mode))
                // TODO: Generate platform_mapping.h from Mapping.pm
                // TODO: Generate world_mapping.h stub
                // TODO: Copy template files
            }
        }

        if (isFullMode) {
            fsa.generateFile(srcPrefix + "dmodel_data.h", generateDModelDataHeader())
            fsa.generateFile(srcPrefix + "interfaces.hpp", generateInterfacesHeader())
            fsa.generateFile(srcPrefix + "utils.h", generateUtilsHeader())
            fsa.generateFile(srcPrefix + "utils.cpp", generateUtilsImpl())
            fsa.generateFile(srcPrefix + "platform_mapping_adapter.cpp", generatePlatformMappingAdapter(solution, platformName))
        }

        if (visualizationEnabled) {
            fsa.generateFile(visualAssetPrefix + "visualization_client.h", generateVisualizationClientHeader())
            fsa.generateFile(visualAssetPrefix + "visualization_server.cpp", generateVisualizationServer())
        }
    }

    /**
     * Extract platform name from solution (e.g., "SimpleArmSerial" -> "platform1")
     * For now, default to "platform1" - can be enhanced to parse from solution metadata
     */
    def String extractPlatformName(Solution solution) {
        return "platform1"
    }

    /**
     * Determine if solution is headless (no visualization)
     * Convention: solution name contains "visual" -> visualization enabled
     */
    def boolean isVisualSolution(Solution solution) {
        val name = solution.name
        return name !== null && name.toLowerCase.contains("visual")
    }

    /**
     * Generate complete platform_engine.cpp matching SimpleArmHeadless structure
     * Structure: Includes → State → Procedures → Functions → Computation → API
     */
    def String generatePlatformEngine(Solution solution, GenerationMode mode) {
        val platformName = extractPlatformName(solution)
        val isHeadless = !isVisualisationEnabled(solution)
        val hasClosedChainDiag = hasClosedChainDiagnostics(solution)
        val trajectoryLoggingEnabled = isTrajectoryLoggingEnabled(solution)

        '''
        // «platformName.toFirstUpper» Physics Engine - Generated from Solution DSL
        // Generation Mode: «mode»
        // Structure: Includes → State → Procedures → Functions → Computation → API

        /* TODO/STUB */

        #pragma region includes
        #include <iostream>
        #include <Eigen/Dense>
        #include <vector>
        #include <memory>
        #include <thread>
        #include <chrono>
        #include <cmath>
        #include <fstream>
        #include <iomanip>
        #include <cstring>
        #include <cstdlib>
        #include "«platformName»_state.hpp"

        «IF mode == GenerationMode.STANDALONE»
        // STANDALONE MODE: Minimal dependencies
        // Uncomment these when ready to integrate with orchestrator:
        // #include "interfaces.hpp"
        // #include "platform_mapping.h"
        // #include "world_mapping.h"
        // #include "utils.h"
        «ELSEIF mode == GenerationMode.STANDALONE_VISUALISATION»
        // STANDALONE_VISUALISATION MODE: Minimal orchestrator with visualisation
        // No mapping or interfaces needed - standalone physics with viz only
        #include "world_mapping.h"
        «ELSEIF mode == GenerationMode.FULL_SIMULATION»
        // FULL_SIMULATION MODE: Full orchestrator integration
        #include "interfaces.hpp"
        #include "platform_mapping.h"
        #include "world_mapping.h"
        #include "utils.h"
        «ELSEIF mode == GenerationMode.FULL_SIMULATION_VISUALISATION»
        // FULL_SIMULATION_VISUALISATION MODE: Full orchestrator integration with visualisation
        #include "interfaces.hpp"
        #include "platform_mapping.h"
        #include "world_mapping.h"
        #include "utils.h"
        «ELSEIF mode == GenerationMode.FULL_SIMULATION_MAPPING»
        // FULL_SIMULATION_MAPPING MODE: Auto-generated mapping from Mapping.pm
        #include "interfaces.hpp"
        #include "platform_mapping.h"  // Auto-generated from Mapping.pm
        #include "world_mapping.h"
        #include "utils.h"
        «ENDIF»
        «IF !isHeadless»
        // Visualization support (generated when solution name indicates visualization)
        #include "visualization_client.h"
        «ENDIF»
        #pragma endregion includes

        // ═══════════════════════════════════════════════════════════════════════════
        // STATE (SolutionDSL: state { ... })
        // ═══════════════════════════════════════════════════════════════════════════
        #pragma region state

        // Platform state (consolidated physics state)
        static «platformName»::State state;

        // Reference bindings for backward compatibility with existing code
        «generateStateReferences(solution, mode, platformName)»

        // Additional state variables
        static double t = 0.0;
        «IF mode == GenerationMode.STANDALONE_VISUALISATION»
        static Eigen::Vector3d g;  // Gravity vector in world coordinates (synchronized from w_mapping)
        «ENDIF»
        // Note: dt is already available from state.dt

        «IF !isHeadless»
        // Geom struct declarations for visualization
«generateGeomDeclarations(solution, platformName)»
        «ENDIF»

        «IF !isHeadless»
        // Visualization runtime state (metadata extracted from Geom records in Solution DSL)
        struct VisualLinkSpec {
            const char* name;
            int shape;       // 0=box, 1=cylinder, 2=sphere, 3=mesh
            double dims[3];  // Shape dimensions (interpretation depends on shape)
        };

        static bool visualization_enabled = true;
        static std::unique_ptr<VisualizationClient> viz_client = nullptr;
        static const VisualLinkSpec ROBOT_VISUAL_LINKS[] = {
«generateRobotVisualLinks(solution)»
        };
        «ENDIF»

        // Logging state
        static std::ofstream transform_log_file;
        static bool transform_logging_enabled = false;
        static std::ofstream torque_log_file;
        static bool torque_logging_enabled = false;
        «IF trajectoryLoggingEnabled»
        static std::ofstream trajectory_log_file;
        static bool trajectory_logging_initialized = false;
        static int trajectory_log_counter = 0;
        «ENDIF»
        // Logging variables declared in utils.cpp - use extern to access the shared globals
        extern std::ofstream high_freq_log_file;
        extern bool high_freq_logging_enabled;
        extern int log_counter;
        extern const double HIGH_FREQ_LOG_PERIOD;
        extern std::ofstream velocity_log_file;
        extern bool velocity_logging_enabled;
        «IF hasClosedChainDiag»
        static bool closed_chain_diag_enabled = false;
        static bool closed_chain_diag_ran = false;
        «ENDIF»

        «IF mode == GenerationMode.STANDALONE»
        // STANDALONE MODE: No mapping globals needed
        // Uncomment these when ready to add sensor/actuator integration:
        // extern "C" {
        // mapping_state_t p_mapping = {};  // Platform mapping (d-model ↔ platform engine)
        // }
        // mapping_state_t w_mapping = {};  // World mapping (world engine → platform sensors)
        «ELSEIF mode == GenerationMode.STANDALONE_VISUALISATION»
        // STANDALONE_VISUALISATION MODE: World mapping for gravity synchronization
        world_mapping_t w_mapping = {
            .g = {0.0, 0.0, -9.81}  // Default gravity in world coordinates
        };
        «ELSE»
        // Platform and world mapping globals
        //
        // Design rationale for global state:
        // 1. C bridge requirement: d-model (C code) needs stable ABI to access platform mapping
        // 2. extern "C" prevents name mangling, ensuring PickPlace.c can link against p_mapping
        // 3. Alternative considered: heap allocation with C API getters/setters
        //    - Rejected: adds indirection, increases coupling, complicates generated d-model code
        // 4. Current approach: global state with clear ownership
        //    - p_mapping: Written by d-model (via registerWrite), read by platform engine
        //    - w_mapping: Written by world mapping (sensor computation), read by platform mapping
        // 5. Thread safety: orchestrator.cpp manages all mutations via mutexes on cycle boundaries
        // 6. This pattern matches RoboSim semantics: platform and world are separate processes
        //    communicating via shared "channels" (here realized as global structs)
        extern "C" {
        mapping_state_t p_mapping = {};  // Platform mapping (d-model ↔ platform engine)
        }
        mapping_state_t w_mapping = {};  // World mapping (world engine → platform sensors)
        «ENDIF»

        #pragma endregion state

        // ═══════════════════════════════════════════════════════════════════════════
        // FUNCTION FORWARD DECLARATIONS
        // ═══════════════════════════════════════════════════════════════════════════
        «generateFunctionForwardDeclarations(solution)»
        «IF hasClosedChainDiag»
        void initClosedChainDiagnostics();
        void runClosedChainDiagnostics();
        «ENDIF»
        «IF !isHeadless»
        void initVisualization();
        void updateRobotVisualization();
        «ENDIF»

        // ═══════════════════════════════════════════════════════════════════════════
        // PROCEDURES (SolutionDSL: procedures { ... })
        // ═══════════════════════════════════════════════════════════════════════════
        #pragma region procedures

        «generateProcedures(solution)»

        #pragma endregion procedures

        // ═══════════════════════════════════════════════════════════════════════════
        // FUNCTIONS (SolutionDSL: functions { ... })
        // ═══════════════════════════════════════════════════════════════════════════
        #pragma region functions

        «generateFunctions(solution)»

        #pragma endregion functions

        // ═══════════════════════════════════════════════════════════════════════════
        // INITIALIZATION (SolutionDSL: state { ... } with initial values)
        // ═══════════════════════════════════════════════════════════════════════════
        #pragma region initialization

        void initGlobals() {
            «generateInitialization(solution)»
            «IF hasClosedChainDiag»
            initClosedChainDiagnostics();
            «ENDIF»

            std::cout << "Physics globals initialized" << std::endl;
            «IF !isHeadless»
            visualization_enabled = true;
            «ENDIF»
        }

        #pragma endregion initialization

        // ═══════════════════════════════════════════════════════════════════════════
        // COMPUTATION (SolutionDSL: computation { ... })
        // ═══════════════════════════════════════════════════════════════════════════
        #pragma region computation

        void physics_update() {
            «IF mode == GenerationMode.FULL_SIMULATION || mode == GenerationMode.FULL_SIMULATION_VISUALISATION || mode == GenerationMode.FULL_SIMULATION_MAPPING»
            // Update platform mapping from world-dependent sensors before physics step.
            {
                auto* platform_world_mapping = get_platform_world_mapping();
                auto* platform_mapping = get_platform_mapping();
                auto* world_engine = get_world_engine();
                if (platform_world_mapping && platform_mapping && world_engine) {
                    sensor_data_t sensors{};
                    platform_world_mapping->computeSensorReadings(
                        world_engine->state(),
                        state,
                        sensors);
                    platform_mapping->updateFromSensors(sensors);
                }
            }
            «ENDIF»
            «generateComputation(solution)»
            «IF !isHeadless»
            if (visualization_enabled) {
                updateRobotVisualization();
            }
            «ENDIF»
        }

        #pragma endregion computation

        «IF hasClosedChainDiag»
        // ═══════════════════════════════════════════════════════════════════════════
        // CLOSED-CHAIN DIAGNOSTICS
        // ═══════════════════════════════════════════════════════════════════════════
        #pragma region diagnostics

        void initClosedChainDiagnostics() {
            const char* env = std::getenv("PHYSICS_CLOSED_CHAIN_DIAGNOSTICS");
            closed_chain_diag_enabled = (env != nullptr && std::strcmp(env, "1") == 0);
        }

        void runClosedChainDiagnostics() {
            if (!closed_chain_diag_enabled || closed_chain_diag_ran) {
                return;
            }
            closed_chain_diag_ran = true;

            const double eps = 1e-6;
            const auto state_backup = state;
            const double dt_backup = dt;
            const double t_backup = t;
            «IF !isHeadless»
            const bool viz_backup = visualization_enabled;
            visualization_enabled = false;
            «ENDIF»
            dt = 0.0;

            // First pass: compute g_pos at initial theta and apply projection
            physics_update();
            const Eigen::VectorXd g_pre = g_pos;
            const auto projected_state = state;

            // Second pass: recompute g_pos for projected theta
            state = projected_state;
            dt = 0.0;
            physics_update();
            const Eigen::VectorXd g_post = g_pos;

            if (G_c.rows() % 6 != 0) {
                std::cout << "[Diagnostics] Skipping G_pos extraction: G_c rows not divisible by 6 (rows="
                          << G_c.rows() << ")" << std::endl;
                state = state_backup;
                dt = dt_backup;
                t = t_backup;
                «IF !isHeadless»
                visualization_enabled = viz_backup;
                «ENDIF»
                return;
            }

            const int n_loop = static_cast<int>(G_c.rows() / 6);
            const int pos_dim = 3 * n_loop;
            Eigen::MatrixXd G_pos = Eigen::MatrixXd::Zero(pos_dim, G_c.cols());
            for (int loop = 0; loop < n_loop; ++loop) {
                for (int row = 0; row < 3; ++row) {
                    for (int col = 0; col < G_c.cols(); ++col) {
                        G_pos((3 * loop + row), col) = G_c((6 * loop + 3 + row), col);
                    }
                }
            }

            if (g_post.size() == pos_dim) {
                const double g_pre_norm = g_pre.norm();
                const double g_pre_max = g_pre.cwiseAbs().maxCoeff();
                const double g_post_norm = g_post.norm();
                const double g_post_max = g_post.cwiseAbs().maxCoeff();
                std::cout << "[Diagnostics] g_pos pre-projection: norm=" << g_pre_norm
                          << ", max_abs=" << g_pre_max << std::endl;
                std::cout << "[Diagnostics] g_pos post-projection: norm=" << g_post_norm
                          << ", max_abs=" << g_post_max << std::endl;
            } else {
                std::cout << "[Diagnostics] g_pos size mismatch: expected " << pos_dim
                          << ", got " << g_post.size() << std::endl;
            }

            const char* dump_env = std::getenv("PHYSICS_CLOSED_CHAIN_DIAGNOSTICS_DUMP");
            const bool dump_enabled = (dump_env != nullptr && std::strcmp(dump_env, "1") == 0);
            if (dump_enabled) {
                auto dump_vec = [](const Eigen::VectorXd& v, const char* name) {
                    std::cout << "[Diagnostics] " << name << " (" << v.size() << "):";
                    for (int i = 0; i < v.size(); ++i) {
                        std::cout << (i == 0 ? " " : ", ") << v(i);
                    }
                    std::cout << std::endl;
                };
                auto dump_mat = [](const Eigen::MatrixXd& m, const char* name, int max_rows, int max_cols) {
                    const int rows = (m.rows() < max_rows) ? m.rows() : max_rows;
                    const int cols = (m.cols() < max_cols) ? m.cols() : max_cols;
                    std::cout << "[Diagnostics] " << name << " (" << m.rows() << "x" << m.cols() << "):" << std::endl;
                    for (int r = 0; r < rows; ++r) {
                        std::cout << "  ";
                        for (int c = 0; c < cols; ++c) {
                            std::cout << m(r, c);
                            if (c + 1 < cols) std::cout << ", ";
                        }
                        if (cols < m.cols()) std::cout << ", ...";
                        std::cout << std::endl;
                    }
                    if (rows < m.rows()) {
                        std::cout << "  ..." << std::endl;
                    }
                };
                dump_vec(g_pre, "g_pos_pre");
                dump_vec(g_post, "g_pos_post");
                dump_mat(G_c, "G_c", 12, 12);
                dump_mat(G_pos, "G_pos", 12, 12);
            }

            // Numeric Jacobian check around projected theta
            const auto base_state = state;
            Eigen::MatrixXd J_num = Eigen::MatrixXd::Zero(pos_dim, theta.size());
            for (int i = 0; i < theta.size(); ++i) {
                state = base_state;
                dt = 0.0;
                «IF !isHeadless»
                visualization_enabled = false;
                «ENDIF»
                theta(i) += eps;
                physics_update();
                const Eigen::VectorXd g_plus = g_pos;

                state = base_state;
                dt = 0.0;
                «IF !isHeadless»
                visualization_enabled = false;
                «ENDIF»
                theta(i) -= eps;
                physics_update();
                const Eigen::VectorXd g_minus = g_pos;

                if (g_plus.size() == pos_dim && g_minus.size() == pos_dim) {
                    J_num.col(i) = (g_plus - g_minus) / (2.0 * eps);
                }
            }

            if (J_num.rows() == G_pos.rows() && J_num.cols() == G_pos.cols()) {
                const Eigen::MatrixXd diff = J_num - G_pos;
                const double max_abs = diff.cwiseAbs().maxCoeff();
                const double rmse = std::sqrt(diff.array().square().sum() /
                                              static_cast<double>(diff.rows() * diff.cols()));
                std::cout << "[Diagnostics] G_pos vs finite-diff: rmse=" << rmse
                          << ", max_abs=" << max_abs << std::endl;
            } else {
                std::cout << "[Diagnostics] Jacobian size mismatch: G_pos="
                          << G_pos.rows() << "x" << G_pos.cols()
                          << ", J_num=" << J_num.rows() << "x" << J_num.cols()
                          << std::endl;
            }

            state = state_backup;
            dt = dt_backup;
            t = t_backup;
            «IF !isHeadless»
            visualization_enabled = viz_backup;
            «ENDIF»
        }

        #pragma endregion diagnostics
        «ENDIF»

        «IF !isHeadless»
        // ═══════════════════════════════════════════════════════════════════════════
        // VISUALIZATION SUPPORT
        // ═══════════════════════════════════════════════════════════════════════════
        #pragma region visualization

        void updateRobotVisualization() {
            if (!viz_client || !viz_client->isConnected()) {
                return;
            }
            const std::size_t linkCount = sizeof(ROBOT_VISUAL_LINKS) / sizeof(ROBOT_VISUAL_LINKS[0]);

            // Construct Bk vector from individual B matrices
            // Check if Bk exists in state, otherwise construct from B_1, B_2, B_3
            std::vector<Eigen::MatrixXd> Bk_vec;
            «val hasBk = if (solution.state !== null && solution.state.variables !== null) {
                solution.state.variables.map[v|v.variable?.name].exists[name|name == "Bk" || name == "B_k"]
            } else {
                false
            }»
            «IF !hasBk»
            // Bk not in state, construct from B_1, B_2, B_3
            Bk_vec = {state.B_1, state.B_2, state.B_3};
            «ELSE»
            // B_k exists in state
            Bk_vec = state.B_k;
            «ENDIF»

            «IF isVelocityLoggingEnabled(solution)»
            // Log transforms to CSV when logging is enabled
            log_transforms(t, Bk_vec);
            «ENDIF»

            // Get T_offset from state (similar to B_k pattern)
            std::vector<Eigen::MatrixXd> T_offset_vec;
            «val hasT_offset = if (solution.state !== null && solution.state.variables !== null) {
                solution.state.variables.map[v|v.variable?.name].exists[name|name == "T_offset"]
            } else {
                false
            }»
            «val hasT_offset_parts = if (solution.state !== null && solution.state.variables !== null) {
                solution.state.variables.map[v|v.variable?.name].exists[name|name !== null && name.matches("T_offset_\\\\d+")]
            } else {
                false
            }»
            «val geomRecordsForVis = extractGeomRecords(solution)»
            «val visLinkCount = geomRecordsForVis.size»
            «IF hasT_offset»
            // T_offset exists in state as sequence
            T_offset_vec = state.T_offset;
            «ELSEIF hasT_offset_parts»
            // T_offset not as sequence, construct from T_offset_1, T_offset_2, ... T_offset_N
            T_offset_vec = {«FOR i : 1 .. visLinkCount»state.T_offset_«i»«IF i < visLinkCount», «ENDIF»«ENDFOR»};
            «ELSE»
            // No T_offset provided by the solution: default to identity offsets so T_geom == B_k.
            // This keeps visualisation working for formulations that only provide body frames.
            T_offset_vec.reserve(linkCount);
            for (std::size_t i = 0; i < linkCount; ++i) {
                T_offset_vec.push_back(Eigen::MatrixXd::Identity(4, 4));
            }
            «ENDIF»

            // Compute T_geom dynamically: T_geom_k = B_k * T_offset_k
            // This is the body-center frame for visualization (formulation-agnostic)
            // Note: We use Bk_vec elements (not B_i) because ForwardKinematics updates B_k[i] not B_i
            std::vector<Eigen::MatrixXd> T_geom_vec;
            T_geom_vec.reserve(Bk_vec.size());
            for (std::size_t i = 0; i < Bk_vec.size() && i < T_offset_vec.size(); ++i) {
                T_geom_vec.push_back(Bk_vec[i] * T_offset_vec[i]);
            }

            std::size_t limit = T_geom_vec.size();
            if (limit > linkCount) {
                limit = linkCount;
            }

            for (std::size_t idx = 0; idx < limit; ++idx) {
                const Eigen::MatrixXd& frame = T_geom_vec[idx];
                if (frame.rows() == 4 && frame.cols() == 4) {
                    Eigen::Matrix4d transform = frame;

                    // T_geom is already at body center, only apply shape-specific rotations
                    const VisualLinkSpec& linkSpec = ROBOT_VISUAL_LINKS[idx];
                    const int shape = linkSpec.shape;

                    if (shape == 1) {
                        // Cylinder: rotate 90° about X to align Y-axis cylinder with Z-axis
                        Eigen::Matrix4d rotation = Eigen::Matrix4d::Identity();
                        rotation(1, 1) = std::cos(M_PI / 2.0);
                        rotation(1, 2) = -std::sin(M_PI / 2.0);
                        rotation(2, 1) = std::sin(M_PI / 2.0);
                        rotation(2, 2) = std::cos(M_PI / 2.0);
                        transform = transform * rotation;
                    }
                    // Box and Sphere: no rotation needed

                    viz_client->sendTransform(ROBOT_VISUAL_LINKS[idx].name, transform, false);
                }
            }
        }

        void initVisualization() {
            visualization_enabled = true;
            if (viz_client) {
                return;  // Early return if already initialized
            }

            viz_client = std::make_unique<VisualizationClient>();

            if (viz_client->connect("127.0.0.1", 9999)) {
                std::cout << "[Robot] Connected to visualization server" << std::endl;

                // Create visualization objects from Geom structs (matching manual implementation pattern)
                const int grey[3] = {128, 128, 128};

                auto shape_from = [](const Geom& g) -> int {
                    const char c = g.geomType[0];
                    return (c == 'b' ? 0 : (c == 'c' ? 1 : (c == 's' ? 2 : 0)));
                };

                «val geomRecords = extractGeomRecords(solution)»
                «val linkCount = geomRecords.size»

                const Geom geoms[] = { «FOR i : 0 ..< linkCount»L«i+1»_geom«IF i < linkCount - 1», «ENDIF»«ENDFOR» };
                «val hasBkForInit = if (solution.state !== null && solution.state.variables !== null) {
                    solution.state.variables.map[v|v.variable?.name].exists[name|name == "Bk" || name == "B_k"]
                } else {
                    false
                }»
                const int count = static_cast<int>(std::min<std::size_t>(«IF hasBkForInit»state.B_k.size()«ELSE»«linkCount»«ENDIF», «linkCount»));

                for (int k = 0; k < count; ++k) {
                    const Geom& g = geoms[k];
                    const int shape = shape_from(g);
                    double dims[3] = {0.0, 0.0, 0.0};
                    const int m = std::min(g.valCount, 3);
                    for (int i = 0; i < m; ++i) dims[i] = g.geomVal[i];
                    const char* name = ROBOT_VISUAL_LINKS[k].name;
                    viz_client->createObject(name, shape, dims, grey);
                }

                updateRobotVisualization();
            } else {
                std::cerr << "[Robot] Failed to connect to visualization server" << std::endl;
                viz_client.reset();
                visualization_enabled = false;
            }
        }

        #pragma endregion visualization
        «ENDIF»

        // ═══════════════════════════════════════════════════════════════════════════
        // API («mode» Mode)
        // ═══════════════════════════════════════════════════════════════════════════
        #pragma region api

        «IF mode == GenerationMode.STANDALONE || mode == GenerationMode.STANDALONE_VISUALISATION»
        // STANDALONE/STANDALONE_VISUALISATION MODE: Simple C API for running physics without orchestrator
        extern "C" {
            void «platformName»_initialise(void) {
                initGlobals();
                «IF !isHeadless»
                initVisualization();
                «ENDIF»
                std::cout << "«platformName.toFirstUpper» physics engine initialized (STANDALONE)" << std::endl;
            }

            void «platformName»_step(void) {
                «IF hasClosedChainDiag»
                runClosedChainDiagnostics();
                «ENDIF»
                physics_update();
            }

            double «platformName»_get_time(void) {
                return t;
            }
        }
        «ELSE»
        // FULL_SIMULATION MODE: Full API with Platform and PlatformEngineImpl classes
        class «platformName.toFirstUpper» : public Platform {
        public:
            «platformName.toFirstUpper»() : Platform("«platformName.toFirstUpper»", 0) {}

            IEntityState& getState() override { return ::state; }
            const IEntityState& getState() const override { return ::state; }
        };

        class PlatformEngineImpl : public IPlatformEngine {
            «platformName.toFirstUpper» platform_entity;

        public:
            PlatformEngineImpl() {}

            void initialise() override {
                initGlobals();
                world_initialize();
                «IF isHeadless»
                std::cout << "Starting simulation (headless - no visualization)" << std::endl;
                «ELSE»
                initVisualization();
                std::cout << "Starting simulation with visualization" << std::endl;
                std::cout << "Open the visualization server link (check server console) to view the robot." << std::endl;
                «ENDIF»
            }

            void update() override {
                «IF hasClosedChainDiag»
                runClosedChainDiagnostics();
                «ENDIF»
                physics_update();
                platform_entity.advanceTime(dt);
            }

            double getTime() const override { return t; }

            Platform& getPlatform() override { return platform_entity; }
            const Platform& getPlatform() const override { return platform_entity; }
        };

        static PlatformEngineImpl platform_engine_instance;
        IPlatformEngine* get_platform_engine() { return &platform_engine_instance; }
        «ENDIF»

        #pragma endregion api

        #pragma region logging

        // All logging functions removed - now centralized in utils.cpp to avoid code duplication
        // Use the following functions from utils.h:
        //   - enable_torque_logging() / disable_torque_logging()
        //   - enable_high_freq_logging() / disable_high_freq_logging()
        //   - enable_velocity_logging() / disable_velocity_logging()
        //   - enable_transform_logging() / disable_transform_logging()
        //   - enable_mapping_debug_logging() / disable_mapping_debug_logging()

        #pragma endregion logging

        // Note: STANDALONE mode now generates a separate orchestrator.cpp with main()
        // The physics engine file no longer contains a main() function
        '''
    }

    /**
     * Check if a type is a custom datatype (defined in the datatypes section)
     */
    def boolean isCustomType(circus.robocalc.robosim.physmod.slnDF.slnDF.Type type) {
        return type instanceof circus.robocalc.robosim.physmod.slnDF.slnDF.TypeRef
    }

    /**
     * Map type with mode awareness (for Geom types in STANDALONE_VISUALISATION mode)
     */
    def String mapType(circus.robocalc.robosim.physmod.slnDF.slnDF.Type type, GenerationMode mode) {
        if (type === null) return "int"

        // Check if this is a custom type reference (TypeRef)
        if (type instanceof circus.robocalc.robosim.physmod.slnDF.slnDF.TypeRef) {
            val typeRef = type as circus.robocalc.robosim.physmod.slnDF.slnDF.TypeRef
            val typeName = if (typeRef.type !== null && typeRef.type.name !== null) {
                typeRef.type.name
            } else {
                // Try to get from source text
                val node = org.eclipse.xtext.nodemodel.util.NodeModelUtils.findActualNodeFor(typeRef)
                if (node !== null) {
                    val text = node.text?.trim
                    if (text !== null && !text.isEmpty) text else "int"
                } else {
                    "int"
                }
            }

            // Return the custom type name as-is (it will be defined as a struct)
            if (typeName !== null && !typeName.isEmpty) {
                return typeName
            }
        }

        // Fall back to standard mapType
        return mapType(type)
    }

    /**
     * Generate state reference bindings with special handling for p_mapping variables in FULL_SIMULATION modes.
     * These allow existing code to reference state.theta as just "theta"
     * 
     * In FULL_SIMULATION modes, p_mapping_* variables are NOT created as state references
     * because they will be read directly from the p_mapping struct in physics_update().
     */
    def String generateStateReferences(Solution solution, GenerationMode mode, String platformName) {
        val state = solution.state
        if (state === null || state.variables === null) return ""

        val sb = new StringBuilder()
        for (varLine : state.variables) {
            val variable = varLine.variable
            if (variable !== null && variable.name !== null) {
                val varName = variable.name
                
                // In FULL_SIMULATION modes, skip p_mapping_* variables as they will be read directly from p_mapping struct
                // Also skip duplicate field name variables (geomType, geomVal) that are incorrectly created by parser
                // Also skip Geom variables (L1_geom, L2_geom, etc.) which are declared as static const in the state section
                val shouldSkipPMapping = (mode == GenerationMode.FULL_SIMULATION || mode == GenerationMode.FULL_SIMULATION_VISUALISATION || mode == GenerationMode.FULL_SIMULATION_MAPPING) && varName.startsWith("p_mapping_")
                val shouldSkipFieldDup = varName == "geomType" || varName == "geomVal"
                val shouldSkipGeom = varName.matches("L\\d+_geom")

                if (shouldSkipPMapping) {
                } else if (shouldSkipFieldDup) {
                    // Silently skip duplicate field name variables
                } else if (shouldSkipGeom) {
                    // Skip Geom variables - they are static const in state section, not state references
                } else {
                    var cppType = mapType(variable.type, mode)
                    // For custom types (like Geom), use qualified name
                    if (isCustomType(variable.type)) {
                        cppType = platformName + "::" + cppType
                    }
                    sb.append("static ").append(cppType).append("& ").append(varName)
                      .append(" = state.").append(varName).append(";\n")
                }
            }
        }

        return sb.toString()
    }

    /**
     * Generate procedures from Solution DSL
     */
    def String generateProcedures(Solution solution) {
        val procedures = solution.procedures
        if (procedures === null || procedures.procedures === null) return ""

        val sb = new StringBuilder()
        for (proc : procedures.procedures) {
            sb.append(generateProcedure(proc)).append("\n\n")
        }
        return sb.toString()
    }

    /**
     * Generate function forward declarations
     */
    def String generateFunctionForwardDeclarations(Solution solution) {
        val functions = solution.functions
        if (functions === null || functions.functions === null) return ""

        val sb = new StringBuilder()
        for (func : functions.functions) {
            if (func.name == 'cos' || func.name == 'sin') {
                // Skip standard trig functions; they map directly to std::cos/sin
            } else {
            val cReturnType = mapType(func.returnType)
            val parameters = if (func.parameters !== null)
                 func.parameters.map[ v | mapType(v.type) + " " + v.name ].join(", ")
               else ""
            sb.append(cReturnType).append(" ").append(func.name).append("(").append(parameters).append(");\n")
            }
        }
        sb.append("\n")
        return sb.toString()
    }

    /**
     * Generate functions from Solution DSL
     */
    def String generateFunctions(Solution solution) {
        val functions = solution.functions
        if (functions === null || functions.functions === null) return ""

        val sb = new StringBuilder()
        for (func : functions.functions) {
            if (func.name == 'cos' || func.name == 'sin') {
                // Skip generating wrappers; expressions call std::cos/sin directly
            } else {
                sb.append(generateFunction(func)).append("\n\n")
            }
        }
        return sb.toString()
    }

    /**
     * Generate initialization code from Solution DSL state initial values
     */
    def String generateInitialization(Solution solution) {
        val state = solution.state
        if (state === null || state.variables === null) return ""

        val regularInits = new StringBuilder()
        val vectorInits = new StringBuilder()
        
        for (varLine : state.variables) {
            val variable = varLine.variable
            if (variable !== null && variable.initialValue !== null) {
                val varName = variable.name
                
                // In FULL_SIMULATION modes, skip initialization of p_mapping_* variables
                // They will be read directly from the p_mapping struct
                // Also skip Geom variables (L1_geom, L2_geom, etc.) which are initialized as static const
                val shouldSkipPMapping = (mode == GenerationMode.FULL_SIMULATION || mode == GenerationMode.FULL_SIMULATION_VISUALISATION || mode == GenerationMode.FULL_SIMULATION_MAPPING) && varName.startsWith("p_mapping_")
                val shouldSkipGeom = varName.matches("L\\d+_geom")

                if (shouldSkipPMapping) {
                } else if (shouldSkipGeom) {
                    // Skip Geom variables - they are initialized as static const in the state section
                } else {
                    val initExpr = generateCppExpression(variable.initialValue)
                val varType = variable.type
                
                // Detect if this is a std::vector initialization that references other variables
                // Pattern: std::vector<...>({ var1, var2, ... })
                val isVectorOfVars = initExpr.contains("std::vector<") && initExpr.contains("decltype(")

                // Handle Geom struct initialization from Solution DSL record expressions
                val isGeomType = variable.type instanceof circus.robocalc.robosim.physmod.slnDF.slnDF.TypeRef && {
                    val typeRef = variable.type as circus.robocalc.robosim.physmod.slnDF.slnDF.TypeRef
                    val typeName = if (typeRef.type !== null && typeRef.type.name !== null) {
                        typeRef.type.name
                    } else {
                        val node = org.eclipse.xtext.nodemodel.util.NodeModelUtils.findActualNodeFor(typeRef)
                        if (node !== null) node.text?.trim else null
                    }
                    typeName !== null && (typeName == "Geom" || typeName.equals("Geom"))
                }
                
                // Choose which StringBuilder to append to: defer vector-of-vars to the end
                val sb = if (isVectorOfVars) vectorInits else regularInits
                
                if (isGeomType && variable.initialValue instanceof circus.robocalc.robosim.physmod.slnDF.slnDF.RecordExp) {
                    // Parse Geom record expression: Geom { geomType = "box", geomVal = [0.5, 0.5, 0.5] }
                    val recordExp = variable.initialValue as circus.robocalc.robosim.physmod.slnDF.slnDF.RecordExp
                    var String geomTypeStr = "\"box\""  // Default
                    var java.util.List<Double> geomVals = newArrayList(0.5, 0.5, 0.5)
                    
                    for (fieldDef : recordExp.definitions) {
                        if (fieldDef.field == "geomType" && fieldDef.value !== null) {
                            val typeVal = generateCppExpression(fieldDef.value)
                            geomTypeStr = typeVal  // Should be a string literal like "box"
                        } else if (fieldDef.field == "geomVal" && fieldDef.value !== null) {
                            geomVals = parseVectorLiteral(fieldDef.value)
                        }
                    }
                    
                    // Initialize Geom struct: { geomType, valCount, {dim0, dim1, dim2} }
                    val dim0 = if (geomVals.size > 0) geomVals.get(0) else 0.0
                    val dim1 = if (geomVals.size > 1) geomVals.get(1) else 0.0
                    val dim2 = if (geomVals.size > 2) geomVals.get(2) else 0.0
                    
                    sb.append("    ").append(varName).append(" = { ")
                      .append(geomTypeStr).append(", ")
                      .append(geomVals.size).append(", {")
                      .append(dim0).append(", ")
                      .append(dim1).append(", ")
                      .append(dim2).append("} };\n")
                } else if (!initExpr.contains("Geom{") && !initExpr.contains("Geom(")) {
                    val isMatrixOrVector = varType instanceof circus.robocalc.robosim.physmod.slnDF.slnDF.MatType ||
                                           varType instanceof circus.robocalc.robosim.physmod.slnDF.slnDF.VecType
                    val isEigenConstructor = initExpr.contains("::Zero(") ||
                                              initExpr.contains("::Identity(") ||
                                              initExpr.contains("::Constant(") ||
                                              initExpr.contains("::Ones(")

                    // For matrix/vector literals (not constructors), we need to resize first before using <<
                    if (isMatrixOrVector && !isEigenConstructor) {
                        // This is a literal, need to resize first before using comma-initializer
                        if (varType instanceof circus.robocalc.robosim.physmod.slnDF.slnDF.MatType) {
                            val matType = varType as circus.robocalc.robosim.physmod.slnDF.slnDF.MatType
                            val rows = matType.rows !== 0 ? matType.rows.toString : "0"
                            val cols = matType.columns !== 0 ? matType.columns.toString : "0"
                            sb.append("    ").append(varName).append(".resize(").append(rows).append(", ").append(cols).append(");\n")
                        } else if (varType instanceof circus.robocalc.robosim.physmod.slnDF.slnDF.VecType) {
                            val vecType = varType as circus.robocalc.robosim.physmod.slnDF.slnDF.VecType
                            val size = vecType.size !== 0 ? vecType.size.toString : "0"
                            sb.append("    ").append(varName).append(".resize(").append(size).append(");\n")
                        }
                        sb.append("    ").append(varName).append(" << ").append(initExpr).append(";\n")
                    } else {
                        // Constructor call or scalar, use = operator
                        sb.append("    ").append(varName).append(" = ").append(initExpr).append(";\n")
                    }
                }
                }
            }
        }

        // Emit regular initializations first, then vector-of-vars initializations
        return regularInits.toString() + vectorInits.toString()
    }

    /**
     * Generate computation block from Solution DSL
     */
    def String generateComputation(Solution solution) {
        val computation = solution.computation
        if (computation === null || computation.lines === null) return ""

        val sb = new StringBuilder()
        
        // In FULL_SIMULATION modes, replace p_mapping_* variable references with struct accesses
        // This handles PlatformMapping constraints that have been flattened to p_mapping_* state variables
        // Build map from flat variable names to struct paths for replacement
        // Only include variables that map to valid struct members (BaseLink exists, IntermediateLink doesn't)
        val flatToStruct = new java.util.HashMap<String, String>()
        if (mode == GenerationMode.FULL_SIMULATION || mode == GenerationMode.FULL_SIMULATION_VISUALISATION || mode == GenerationMode.FULL_SIMULATION_MAPPING) {
            if (solution.state !== null && solution.state.variables !== null) {
                for (varLine : solution.state.variables) {
                    val variable = varLine.variable
                    if (variable !== null && variable.name !== null) {
                        val flatVarName = variable.name
                        if (flatVarName.startsWith("p_mapping_")) {
                            // Map all p_mapping_* variables to their struct paths
                            // The struct hierarchy is generated based on the p-model's link/sensor structure
                            val structPath = convertFlatNameToStructPath(flatVarName)
                            flatToStruct.put(flatVarName, structPath)
                        }
                    }
                }
            }
        }
        
        for (stmt : computation.lines) {
            var stmtText = generateCppStatement(stmt)
            
            // In FULL_SIMULATION modes, replace references to p_mapping_* variables with struct accesses
            // For variables that don't exist in the struct (like WristJoint), we need to handle them specially
            // Check if this statement assigns from a p_mapping_* variable
            var boolean replaced = false
            for (entry : flatToStruct.entrySet) {
                val flatName = entry.key
                if (stmtText.contains(flatName)) {
                    val structPath = entry.value
                    // Replace all occurrences of flatName with structPath
                    stmtText = stmtText.replace(flatName, structPath)
                    replaced = true
                }
            }
            
            // For p_mapping_* variables not in the struct (e.g., WristJoint on IntermediateLink), replace with 0.0
            val pMappingPattern = java.util.regex.Pattern.compile("p_mapping_[A-Za-z0-9_]+")
            val matcher = pMappingPattern.matcher(stmtText)
            var String lastMatch = null
            while (matcher.find()) {
                val foundVar = matcher.group()
                // Replace with 0.0 if it's not in our mapping (e.g., IntermediateLink/WristJoint)
                if (!flatToStruct.containsKey(foundVar) && foundVar.startsWith("p_mapping_")) {
                    stmtText = stmtText.replace(foundVar, "0.0")
                    lastMatch = foundVar
                }
            }
            
            sb.append("    ").append(stmtText).append("\n")
        }
        
        // Update time after computation (matches manual implementation pattern)
        sb.append("    \n")
        sb.append("    // Update time for next iteration\n")
        sb.append("    t += dt;\n")

        // Add trajectory logging if enabled via system property (log after time update)
        if (isTrajectoryLoggingEnabled(solution)) {
            sb.append("\n")
            sb.append("    if (!trajectory_logging_initialized) {\n")
            sb.append("        trajectory_log_file.open(\"trajectory_generated.csv\");\n")
            sb.append("        if (trajectory_log_file.is_open()) {\n")
            sb.append("            trajectory_log_file << \"time\";\n")
            sb.append("            for (int i = 0; i < theta.size(); ++i) {\n")
            sb.append("                trajectory_log_file << \",theta\" << i;\n")
            sb.append("            }\n")
            sb.append("            trajectory_log_file << std::endl;\n")
            sb.append("            trajectory_log_file << std::fixed << std::setprecision(6);\n")
            sb.append("            trajectory_logging_initialized = true;\n")
            sb.append("        }\n")
            sb.append("    }\n")
            sb.append("    if (trajectory_logging_initialized) {\n")
            sb.append("        trajectory_log_file << t;\n")
            sb.append("        for (int i = 0; i < theta.size(); ++i) {\n")
            sb.append("            trajectory_log_file << \",\" << theta(i);\n")
            sb.append("        }\n")
            sb.append("        trajectory_log_file << std::endl;\n")
            sb.append("        trajectory_log_counter++;\n")
            sb.append("        if ((trajectory_log_counter % 100) == 0) {\n")
            sb.append("            trajectory_log_file.flush();\n")
            sb.append("        }\n")
            sb.append("    }\n")
        }
        
        // Add velocity logging if enabled via system property (log after time update)
        if (isVelocityLoggingEnabled(solution)) {
            sb.append("\n")
            sb.append("    // Log velocity data for trajectory comparison\n")
            sb.append("    log_velocity(t, theta, d_theta, tau, M_mass);\n")
        }

        return sb.toString()
    }
    
    /**
     * Extract platform mapping reads from state variables.
     * Scans state for p_mapping_* variables and constructs p_mapping struct access paths.
     * Returns a map of tau(i) -> p_mapping.Platform.Link.Joint.Actuator.TorqueIn
     */
    def java.util.Map<String, String> extractPlatformMappingReads(Solution solution) {
        val result = new java.util.LinkedHashMap<String, String>()
        
        // Scan state variables for p_mapping_* variables
        if (solution.state !== null && solution.state.variables !== null) {
            for (varLine : solution.state.variables) {
                val variable = varLine.variable
                if (variable !== null && variable.name !== null) {
                    val varName = variable.name
                    // Look for p_mapping_* variables (TorqueIn, measurement, etc.)
                    if (varName.startsWith("p_mapping_")) {
                        // Extract the index by searching computation for tau(i) = varName assignments
                        // This will only work for torque inputs that are assigned to tau, but we check all p_mapping variables
                        val tauVar = findTauAssignment(solution, varName)
                        if (tauVar !== null) {
                            // Convert flat name to struct access path
                            // p_mapping_SimpleArm_BaseLink_ElbowJoint_ElbowActuator_TorqueIn
                            // -> p_mapping.SimpleArm.BaseLink.ElbowJoint.ElbowJointMotor.TorqueIn
                            val structPath = convertFlatNameToStructPath(varName)
                            result.put(tauVar, structPath)
                        }
                    }
                }
            }
        }
        
        return result
    }
    
    /**
     * Find which tau(i) variable is assigned from a given p_mapping_* variable.
     * Searches computation statements for patterns like: tau(i) = p_mapping_*_TorqueIn
     */
    def String findTauAssignment(Solution solution, String pmappingVarName) {
        if (solution.computation === null || solution.computation.lines === null) return null
        
        for (stmt : solution.computation.lines) {
            val stmtText = stmt.toString
            // Look for patterns like: subvector(tau)(0,1) = p_mapping_SimpleArm_*_TorqueIn
            if (stmtText.contains(pmappingVarName) && stmtText.contains("tau")) {
                // Extract tau index from subvector(tau)(index,1)
                val pattern = java.util.regex.Pattern.compile("subvector\\(tau\\)\\((\\d+),1\\)\\s*=\\s*" + java.util.regex.Pattern.quote(pmappingVarName))
                val matcher = pattern.matcher(stmtText)
                if (matcher.find()) {
                    val index = matcher.group(1)
                    return "tau(" + index + ")"
                }
            }
        }
        return null
    }
    
    /**
     * Convert flat p_mapping variable name to struct access path.
     * Input: p_mapping_SimpleArm_BaseLink_ElbowJoint_ElbowActuator_TorqueIn
     * Output: p_mapping.SimpleArm.BaseLink.ElbowJoint.ElbowJointMotor.TorqueIn
     */
    def String convertFlatNameToStructPath(String flatName) {
        // Remove p_mapping_ prefix
        var path = flatName.substring("p_mapping_".length)
        // Replace underscores with dots
        path = path.replace("_", ".")
        // Fix actuator naming: XActuator -> XJointMotor
        path = path.replaceAll("(\\w+)Actuator", "$1JointMotor")
        // Prepend p_mapping
        return "p_mapping." + path
    }
    
    /**
     * Parse a platform mapping constraint string to extract the assignment.
     * Input: " (tau(0)) [ t == t] ==p_mapping.SimpleArmSerial.IntermediateLink.WristJoint.WristActuator.TorqueIn"
     * Output: Pair<"tau(0)", "p_mapping.SimpleArm.IntermediateLink.WristJoint.WristActuator.TorqueIn">
     * 
     * NOTE: This function is currently not used as constraints are flattened in Stage 1.
     * Kept for potential future use if Stage 1 is modified to preserve constraints.
     */
    def java.util.Map.Entry<String, String> parsePlatformMappingConstraint(String constraintText) {
        try {
            // Extract tau(index)
            val tauPattern = java.util.regex.Pattern.compile("\\(tau\\((\\d+)\\)\\)")
            val tauMatcher = tauPattern.matcher(constraintText)
            if (!tauMatcher.find()) return null
            val tauIndex = tauMatcher.group(1)
            val tauVar = "tau(" + tauIndex + ")"
            
            // Extract p_mapping path
            val mappingPattern = java.util.regex.Pattern.compile("==\\s*p_mapping\\.([\\w\\.]+)")
            val mappingMatcher = mappingPattern.matcher(constraintText)
            if (!mappingMatcher.find()) return null
            val mappingPath = mappingMatcher.group(1)
            
            // Convert path from slnRef format to C++ struct access
            // SimpleArmSerial.BaseLink.ElbowJoint.ElbowActuator.TorqueIn
            // -> SimpleArm.BaseLink.ElbowJoint.ElbowJointMotor.TorqueIn
            val cppPath = convertMappingPathToCpp(mappingPath)
            val fullPath = "p_mapping." + cppPath
            
            return new java.util.AbstractMap.SimpleEntry(tauVar, fullPath)
        } catch (Exception e) {
            System.err.println("Failed to parse platform mapping constraint: " + constraintText)
            return null
        }
    }
    
    /**
     * Convert mapping path from slnRef format to C++ struct format.
     * Handles platform name normalization (SimpleArmSerial -> SimpleArm) and
     * actuator name normalization (ElbowActuator -> ElbowJointMotor).
     */
    def String convertMappingPathToCpp(String mappingPath) {
        var result = mappingPath
        // Preserve platform names as-is to support arbitrary scenarios (e.g., Acrobot).
        // Only normalize CamelCase actuator suffixes (XActuator -> XJointMotor) when present.
        // Note: snake_case actuator names (e.g., elbow_actuator) are intentionally left unchanged.
        result = result.replaceAll("(\\w+)Actuator", "$1JointMotor")
        return result
    }

    /**
     * Generate state header file (platform<N>_state.hpp)
     * Contains the State struct with all variables from Solution DSL state section
     */
    def String generateStateHeader(Solution solution, String platformName, GenerationMode mode, boolean visualizationEnabled) {
        val state = solution.state
        if (state === null) {
            return generateDefaultStateHeader(platformName, mode, visualizationEnabled)
        }

        '''
        // «platformName.toFirstUpper» State - Generated from Solution DSL
        // This header defines the consolidated state structure for the platform physics engine

        #ifndef «platformName.toUpperCase»_STATE_HPP
        #define «platformName.toUpperCase»_STATE_HPP

        #include <Eigen/Dense>
        #include <vector>
        «IF mode != GenerationMode.STANDALONE && mode != GenerationMode.STANDALONE_VISUALISATION»
        #include "interfaces.hpp"
        «ENDIF»

        namespace «platformName» {

        «generateCustomDataTypes(solution)»

        «IF mode == GenerationMode.STANDALONE || mode == GenerationMode.STANDALONE_VISUALISATION»
        struct State {
        «ELSE»
        struct State : public IEntityState {
        «ENDIF»
            // State variables from Solution DSL
            «FOR varLine : state.variables»
            «val variable = varLine.variable»
            «IF variable !== null && variable.name !== null && variable.name != "geomType" && variable.name != "geomVal" && !variable.name.matches("L\\d+_geom")»
            «mapType(variable.type, mode)» «variable.name»«generateDefaultValue(variable.type)»;
            «ENDIF»
            «ENDFOR»

            «IF mode != GenerationMode.STANDALONE && mode != GenerationMode.STANDALONE_VISUALISATION»
            // IEntityState interface implementation
            Eigen::Vector3d position;
            Eigen::Vector3d velocity;
            Eigen::Vector3d orientation;  // Euler angles or quaternion representation

            State() : position(Eigen::Vector3d::Zero()),
                     velocity(Eigen::Vector3d::Zero()),
                     orientation(Eigen::Vector3d::Zero()) {}
            «ENDIF»
        };

        }  // namespace «platformName»

        #endif  // «platformName.toUpperCase»_STATE_HPP
        '''
    }

    /**
     * Generate default state header if Solution DSL doesn't have state section
     */
    def String generateDefaultStateHeader(String platformName, GenerationMode mode, boolean visualizationEnabled) {
        '''
        #ifndef «platformName.toUpperCase»_STATE_HPP
        #define «platformName.toUpperCase»_STATE_HPP

        #include <Eigen/Dense>
        «IF mode != GenerationMode.STANDALONE»
        #include "interfaces.hpp"
        «ENDIF»

        namespace «platformName» {

        // No custom datatypes to generate (no Solution provided)

        «IF mode == GenerationMode.STANDALONE»
        struct State {
        «ELSE»
        struct State : public IEntityState {
        «ENDIF»
            Eigen::Vector3d position;
            Eigen::Vector3d velocity;
            Eigen::Vector3d orientation;

            State() : position(Eigen::Vector3d::Zero()),
                     velocity(Eigen::Vector3d::Zero()),
                     orientation(Eigen::Vector3d::Zero()) {}
        };

        }  // namespace «platformName»

        #endif  // «platformName.toUpperCase»_STATE_HPP
        '''
    }

    /**
     * Generate C++ struct definitions for all custom datatypes defined in Solution DSL
     */
    def String generateCustomDataTypes(Solution solution) {
        val datatypes = solution?.datatypes
        if (datatypes === null) return ""

        val sb = new StringBuilder()
        sb.append("// Custom datatypes from Solution DSL\n")

        for (customType : datatypes.datatypes) {
            if (customType !== null && customType.name !== null) {
                val typeName = customType.name
                val typeSpec = customType.type

                if (typeSpec instanceof circus.robocalc.robosim.physmod.slnDF.slnDF.DataType) {
                    // Generate struct for record type
                    sb.append("struct ").append(typeName).append(" {\n")

                    for (field : typeSpec.fields) {
                        if (field !== null && field.name !== null && field.type !== null) {
                            sb.append("    ")
                            val fieldTypeName = mapType(field.type)
                            sb.append(fieldTypeName).append(" ").append(field.name).append(";\n")
                        }
                    }

                    sb.append("};\n\n")
                }
                // Could also handle EnumType here if needed
            }
        }

        return sb.toString()
    }

    /**
     * Generate default initialization value for a type
     */
    def String generateDefaultValue(circus.robocalc.robosim.physmod.slnDF.slnDF.Type type) {
        if (type === null) return ""

        // Check if it's a custom type reference (TypeRef)
        if (type instanceof circus.robocalc.robosim.physmod.slnDF.slnDF.TypeRef) {
            // Custom types have default constructors
            return ""
        }

        val typeName = type.eClass.name
        switch (typeName) {
            case "IntType": return " = 0"
            case "FloatType": return " = 0.0"
            case "BoolType": return " = false"
            case "VecType": return ""  // Eigen types have default constructors
            case "MatType": return ""
            case "SeqType": return ""  // std::vector has default constructor
            default: return ""
        }
    }

    /**
     * Helper class to hold link visualization data extracted from Geom records
     */
    static class LinkVisualSpec {
        public String name                              // Link name (e.g., "robot/link_1")
        public String geomType                          // Shape type string ("box", "cylinder", "sphere", "mesh")
        public java.util.List<Double> dims              // Dimensions (interpretation depends on shape)
        public int linkIndex                            // Link index (1, 2, 3, ...)
    }

    /**
     * Extract decomposed Geom data from Solution DSL state section
     * Looks for geom_XX_type (string) and geom_XX_dims (vec) variable pairs
     * Returns list of LinkVisualSpec sorted by link index
     */
    def java.util.List<LinkVisualSpec> extractGeomRecords(Solution solution) {
        val result = new java.util.ArrayList<LinkVisualSpec>()
        val state = solution?.state
        if (state === null || state.variables === null) {
            return result
        }

        // First, try to find proper Geom record variables (L1_geom, L2_geom, etc.)
        val geomVariables = new java.util.ArrayList<circus.robocalc.robosim.physmod.slnDF.slnDF.Variable>()
        for (varLine : state.variables) {
            val variable = varLine?.variable
            if (variable !== null && variable.name !== null && variable.name.matches("L\\d+_geom")) {
                geomVariables.add(variable)
            }
        }

        // If we found proper Geom record variables, use them
        if (!geomVariables.isEmpty) {
            for (geomVar : geomVariables) {
                val varName = geomVar.name
                // Extract link index from name (e.g., L1_geom -> 1, L2_geom -> 2)
                val indexStr = varName.substring(1, varName.indexOf("_"))
                try {
                    val linkIndex = Integer.parseInt(indexStr)

                    // Extract fields from the record initialization
                    val initValue = geomVar.initialValue

                    // Handle both RecordExp and Primary (which may wrap a RecordExp via its base)
                    var circus.robocalc.robosim.physmod.slnDF.slnDF.RecordExp recordExp = null
                    if (initValue instanceof circus.robocalc.robosim.physmod.slnDF.slnDF.RecordExp) {
                        recordExp = initValue as circus.robocalc.robosim.physmod.slnDF.slnDF.RecordExp
                    } else if (initValue instanceof circus.robocalc.robosim.physmod.slnDF.slnDF.Primary) {
                        val primary = initValue as circus.robocalc.robosim.physmod.slnDF.slnDF.Primary
                        if (primary.base instanceof circus.robocalc.robosim.physmod.slnDF.slnDF.RecordExp) {
                            recordExp = primary.base as circus.robocalc.robosim.physmod.slnDF.slnDF.RecordExp
                        }
                    }
                    
                    if (recordExp !== null) {
                        var String geomType = null
                        var java.util.List<Double> dims = null

                        for (fieldDef : recordExp.definitions) {
                            val fieldName = fieldDef.field
                            val fieldValue = fieldDef.value

                            if (fieldName == "geomType") {
                                // Extract string value - handle Primary wrapping
                                var circus.robocalc.robosim.physmod.slnDF.slnDF.StringExp stringExp = null
                                if (fieldValue instanceof circus.robocalc.robosim.physmod.slnDF.slnDF.StringExp) {
                                    stringExp = fieldValue as circus.robocalc.robosim.physmod.slnDF.slnDF.StringExp
                                } else if (fieldValue instanceof circus.robocalc.robosim.physmod.slnDF.slnDF.Primary) {
                                    val primary = fieldValue as circus.robocalc.robosim.physmod.slnDF.slnDF.Primary
                                    if (primary.base instanceof circus.robocalc.robosim.physmod.slnDF.slnDF.StringExp) {
                                        stringExp = primary.base as circus.robocalc.robosim.physmod.slnDF.slnDF.StringExp
                                    }
                                }
                                if (stringExp !== null) {
                                    geomType = stringExp.value
                                    // Remove quotes if present
                                    if (geomType !== null && geomType.startsWith("\"")) {
                                        geomType = geomType.substring(1, geomType.length - 1)
                                    }
                                }
                            } else if (fieldName == "geomVal") {
                                // Extract vector value
                                dims = parseVectorLiteral(fieldValue)
                            }
                        }

                        if (geomType !== null && dims !== null && !dims.isEmpty) {
                            val spec = new LinkVisualSpec()
                            spec.name = "robot/link_" + linkIndex
                            spec.geomType = geomType
                            spec.dims = dims
                            spec.linkIndex = linkIndex
                            result.add(spec)
                        }
                    }
                } catch (NumberFormatException e) {
                    // Ignore invalid indices
                }
            }
        } else {
            // Fallback: Look for flattened pattern (geom_11_type, geom_11_dims, etc.) for backward compatibility
            val variableMap = new java.util.HashMap<String, circus.robocalc.robosim.physmod.slnDF.slnDF.Variable>()
            for (varLine : state.variables) {
                val variable = varLine?.variable
                if (variable !== null && variable.name !== null) {
                    variableMap.put(variable.name, variable)
                }
            }

            val processedGeoms = new java.util.HashSet<String>()
            for (varLine : state.variables) {
                val variable = varLine?.variable
                if (variable !== null && variable.name !== null) {
                    val varName = variable.name
                    // Match pattern: geom_<digit><digit>_type (e.g., geom_11_type, geom_21_type)
                    if (varName.matches("geom_\\d+_type")) {
                        val baseGeomName = varName.substring(0, varName.length - 5) // Remove "_type" suffix

                        // Skip if already processed
                        if (!processedGeoms.contains(baseGeomName)) {
                            processedGeoms.add(baseGeomName)

                            // Extract link index from variable name (e.g., geom_11_type -> 1, geom_21_type -> 2)
                            // Pattern is geom_XY where X is the link index
                            val indexStr = baseGeomName.substring(5, 6) // First digit after underscore (link index)
                            try {
                                val linkIndex = Integer.parseInt(indexStr)

                                // Look for corresponding geom_XX_dims variable
                                val dimsVarName = baseGeomName + "_dims"
                                val dimsVariable = variableMap.get(dimsVarName)

                                if (dimsVariable !== null) {
                                    // Extract geomType from geom_XX_type
                                    var String geomType = null
                                    var circus.robocalc.robosim.physmod.slnDF.slnDF.Expression typeInitValue = variable.initialValue

                                    // Unwrap Primary expression if needed
                                    if (typeInitValue instanceof circus.robocalc.robosim.physmod.slnDF.slnDF.Primary) {
                                        val primary = typeInitValue as circus.robocalc.robosim.physmod.slnDF.slnDF.Primary
                                        typeInitValue = primary.base
                                    }

                                    if (typeInitValue instanceof circus.robocalc.robosim.physmod.slnDF.slnDF.StringExp) {
                                        val stringExp = typeInitValue as circus.robocalc.robosim.physmod.slnDF.slnDF.StringExp
                                        geomType = stringExp.value
                                        // Remove quotes if present
                                        if (geomType !== null && geomType.startsWith("\"")) {
                                            geomType = geomType.substring(1, geomType.length - 1)
                                        }
                                    }

                                    // Extract dimensions from geom_XX_dims
                                    val dims = parseVectorLiteral(dimsVariable.initialValue)

                                    if (geomType !== null && dims !== null && !dims.isEmpty) {
                                        val spec = new LinkVisualSpec()
                                        spec.name = "robot/link_" + linkIndex
                                        spec.geomType = geomType
                                        spec.dims = dims
                                        spec.linkIndex = linkIndex
                                        result.add(spec)
                                    }
                                }
                            } catch (NumberFormatException e) {
                                // Ignore invalid indices
                            }
                        }
                    }
                }
            }
        }

        // Sort by link index
        java.util.Collections.sort(result, [a, b| a.linkIndex.compareTo(b.linkIndex)])

        // Use generic, stable names for links to ensure create/update consistency
        for (i : 0 ..< result.size) {
            val spec = result.get(i)
            spec.name = "robot/link_" + (i + 1)
        }

        return result
    }

    /**
     * Parse a Geom RecordExp to extract geomType and geomVal
     */
    def LinkVisualSpec parseGeomRecord(circus.robocalc.robosim.physmod.slnDF.slnDF.RecordExp recordExp, int linkIndex) {
        var String geomType = null
        var java.util.List<Double> dims = null

        for (fieldDef : recordExp.definitions) {
            val fieldName = fieldDef.field
            val fieldValue = fieldDef.value

            if (fieldName == "geomType") {
                // Extract string value
                if (fieldValue instanceof circus.robocalc.robosim.physmod.slnDF.slnDF.StringExp) {
                    val stringExp = fieldValue as circus.robocalc.robosim.physmod.slnDF.slnDF.StringExp
                    geomType = stringExp.value
                    // Remove quotes if present
                    if (geomType !== null && geomType.startsWith("\"")) {
                        geomType = geomType.substring(1, geomType.length - 1)
                    }
                }
            } else if (fieldName == "geomVal") {
                // Extract vector literal
                dims = parseVectorLiteral(fieldValue)
            }
        }

        if (geomType !== null && dims !== null) {
            val spec = new LinkVisualSpec()
            spec.name = "robot/link_" + linkIndex
            spec.geomType = geomType
            spec.dims = dims
            spec.linkIndex = linkIndex
            return spec
        }

        return null
    }

    /**
     * Parse a vector literal expression to extract numeric values
     */
    def java.util.List<Double> parseVectorLiteral(circus.robocalc.robosim.physmod.slnDF.slnDF.Expression expr) {
        val result = new java.util.ArrayList<Double>()

        var circus.robocalc.robosim.physmod.slnDF.slnDF.Expression actualExpr = expr

        // Unwrap Primary expression if needed
        if (actualExpr instanceof circus.robocalc.robosim.physmod.slnDF.slnDF.Primary) {
            val primary = actualExpr as circus.robocalc.robosim.physmod.slnDF.slnDF.Primary
            actualExpr = primary.base
        }

        if (actualExpr instanceof circus.robocalc.robosim.physmod.slnDF.slnDF.VectorOrMatrix) {
            val vecMat = actualExpr as circus.robocalc.robosim.physmod.slnDF.slnDF.VectorOrMatrix
            for (row : vecMat.rows) {
                if (row instanceof circus.robocalc.robosim.physmod.slnDF.slnDF.RowLiteral) {
                    val rowLit = row as circus.robocalc.robosim.physmod.slnDF.slnDF.RowLiteral
                    for (elem : rowLit.elements) {
                        val value = extractNumericValue(elem)
                        if (value !== null) {
                            result.add(value)
                        }
                    }
                }
            }
        }

        return result
    }

    /**
     * Extract numeric value from expression
     */
    def Double extractNumericValue(circus.robocalc.robosim.physmod.slnDF.slnDF.Expression expr) {
        if (expr instanceof circus.robocalc.robosim.physmod.slnDF.slnDF.IntegerExp) {
            val intExp = expr as circus.robocalc.robosim.physmod.slnDF.slnDF.IntegerExp
            return Double.valueOf(intExp.value)
        } else if (expr instanceof circus.robocalc.robosim.physmod.slnDF.slnDF.FloatExp) {
            val floatExp = expr as circus.robocalc.robosim.physmod.slnDF.slnDF.FloatExp
            return Double.valueOf(floatExp.value)
        } else if (expr instanceof circus.robocalc.robosim.physmod.slnDF.slnDF.Unary) {
            val unary = expr as circus.robocalc.robosim.physmod.slnDF.slnDF.Unary
            val operandValue = extractNumericValue(unary.operand)
            if (operandValue !== null) {
                return -operandValue
            }
        }
        return null
    }

    /**
     * Map geomType string to integer shape code
     * 0=box, 1=cylinder, 2=sphere, 3=mesh
     */
    def int geomTypeToShapeCode(String geomType) {
        switch (geomType.toLowerCase) {
            case "box": return 0
            case "cylinder": return 1
            case "sphere": return 2
            case "mesh": return 3
            default: return 0  // Default to box
        }
    }

    /**
     * Generate Geom struct declarations (static const Geom L1_geom = {...}, etc.)
     * Matches manual implementation pattern in Examples/CPP_tests/manualImplementationCPP
     */
    def String generateGeomDeclarations(Solution solution, String platformName) {
        // Extract Geom records from state variables (L1_geom, L2_geom, L3_geom)
        val geomRecords = extractGeomRecords(solution)

        val sb = new StringBuilder()

        // Generate simple C-style Geom struct definition for visualization
        sb.append("// Geometry datatypes\n")
        sb.append("struct Geom { const char* geomType; int valCount; double geomVal[3]; };\n")

        // Generate static const Geom declarations from extracted records
        if (geomRecords.isEmpty) {
            throw new IllegalStateException(
                "[T5 Generator] Visualisation is enabled but no Geom records were found in the Solution. " +
                "Please provide Geom records (e.g., L1_geom) or disable visualisation.")
        }

        // Generate static const Geom variables from extracted records
        for (i : 0 ..< geomRecords.size) {
            val geom = geomRecords.get(i)
            val linkNum = i + 1  // L1, L2, L3, etc.
            val geomTypeStr = geom.geomType
            val dimList = geom.dims
            val valCount = dimList.size

            // Pad dimensions array to 3 elements
            val dim0 = if (dimList.size > 0) dimList.get(0) else 0.0
            val dim1 = if (dimList.size > 1) dimList.get(1) else 0.0
            val dim2 = if (dimList.size > 2) dimList.get(2) else 0.0

            // Determine comment based on link position (gripper, intermediate, base)
            val comment = if (i == 0) "gripper" else if (i == geomRecords.size - 1) "base" else "intermediate"

            sb.append("static const Geom L").append(linkNum).append("_geom = { \"")
              .append(geomTypeStr).append("\", ")
              .append(valCount).append(", {")
              .append(dim0).append(", ")
              .append(dim1).append(", ")
              .append(dim2).append("} };  // ").append(comment).append("\n")
        }

        return sb.toString()
    }

    /**
     * Generate ROBOT_VISUAL_LINKS array from extracted Geom records
     */
    def String generateRobotVisualLinks(Solution solution) {
        val geomRecords = extractGeomRecords(solution)

        if (geomRecords.isEmpty) {
            throw new IllegalStateException(
                "[T5 Generator] Visualisation is enabled but no Geom records were found in the Solution. " +
                "Please provide Geom records (e.g., L1_geom) or disable visualisation.")
        }

        val sb = new StringBuilder()
        for (i : 0 ..< geomRecords.size) {
            val geom = geomRecords.get(i)
            val shapeCode = geomTypeToShapeCode(geom.geomType)

            // Pad dimensions array to 3 elements (fill with 0.0)
            val dimList = geom.dims
            val dim0 = if (dimList.size > 0) dimList.get(0) else 0.0
            val dim1 = if (dimList.size > 1) dimList.get(1) else 0.0
            val dim2 = if (dimList.size > 2) dimList.get(2) else 0.0

            sb.append("    {\"").append(geom.name).append("\", ")
              .append(shapeCode).append(", {")
              .append(dim0).append(", ")
              .append(dim1).append(", ")
              .append(dim2).append("}}")

            if (i < geomRecords.size - 1) {
                sb.append(",\n")
            }
        }

        return sb.toString()
    }

    /**
     * Generate minimal orchestrator.h for STANDALONE_VISUALISATION mode
     * Simple header with no thread management - just main entry point
     */
    def String generateMinimalOrchestratorHeader(Solution solution, String platformName) {
        '''
        #ifndef ORCHESTRATOR_H
        #define ORCHESTRATOR_H

        // ============================================================================
        // Minimal Orchestrator Interface: STANDALONE_VISUALISATION Mode
        // ============================================================================
        //
        // This is a minimal orchestrator for standalone physics simulation with
        // optional visualization support.
        //
        // No thread management - just a simple main() that:
        //   - Initializes the platform engine
        //   - Runs a timing loop calling platform_step()
        //   - Optionally sends visualization data
        //
        // Stub sections (commented out):
        //   - D-model interface (no discrete controller integration)
        //   - World engine (no external world simulation)
        //   - Platform mapping (no d-model ↔ platform mapping)
        // ============================================================================

        // No public API needed - main() is the entry point

        #endif // ORCHESTRATOR_H
        '''
    }

    /**
     * Generate minimal orchestrator.cpp for STANDALONE and STANDALONE_VISUALISATION modes
     * Simple main() with timing loop and optional visualisation
     */
    def String generateMinimalOrchestrator(Solution solution, String platformName, GenerationMode mode) {
        val modeName = if (mode == GenerationMode.STANDALONE_VISUALISATION) "STANDALONE_VISUALISATION" else "STANDALONE"
        val hasVisualization = (mode == GenerationMode.STANDALONE_VISUALISATION)

        '''
        /*
         * Minimal Orchestrator - «modeName» Mode
         * ----------------------------------------------------------
         * Simple standalone physics simulation«IF hasVisualization» with visualization support«ENDIF».
         *
         * Generated for: «solution.name»
         * Platform: «platformName»
         *
         * This orchestrator provides minimal infrastructure:
         *   - Timing loop (sim_time, dt, max_time)
         *   - Platform engine calls (initialise, step)
         «IF hasVisualization»
         *   - Visualization integration
         «ENDIF»
         *
         * Stub sections (commented out for standalone mode):
         *   - D-model interface (#ifdef HAS_DMODEL_INTERFACE)
         *   - World engine (#ifdef HAS_WORLD_ENGINE)
         *   - Platform mapping (#ifdef HAS_PLATFORM_MAPPING)
         */

        #include <iostream>
        #include <fstream>
        #include <unistd.h>
        #include "«platformName»_state.hpp"

        // Platform engine API declarations (standalone mode)
        extern "C" {
            void «platformName»_initialise(void);
            void «platformName»_step(void);
            double «platformName»_get_time(void);
        }
        
        // Access to platform state for trajectory logging
        namespace «platformName» {
            extern State state;
        }

        «IF hasVisualization»
        // Visualization includes (conditional)
        #ifdef HAS_VISUALIZATION
        #include "visualization_client.h"
        void updateRobotVisualization();  // Defined in platform engine
        #endif
        «ENDIF»

        // Stub out d-model interface (not needed for standalone physics)
        // #ifdef HAS_DMODEL_INTERFACE
        // #include "dmodel_interface.h"
        // extern void dmodel_main();
        // #endif

        // Stub out world engine (not needed for standalone physics)
        // #ifdef HAS_WORLD_ENGINE
        // #include "world_engine.h"
        // extern void world_update();
        // #endif

        // Stub out platform mapping (not needed without d-model)
        // #ifdef HAS_PLATFORM_MAPPING
        // #include "platform_mapping.h"
        // extern void update_platform_mapping();
        // #endif

        int main() {
            std::cout << "==============================================\n";
            std::cout << "  Minimal Orchestrator («modeName»)\n";
            std::cout << "  Platform: «platformName»\n";
            std::cout << "==============================================\n\n";

            // Initialize platform physics engine
            «platformName»_initialise();

            «IF hasVisualization»
            #ifdef HAS_VISUALIZATION
            std::cout << "Visualization support enabled\n";
            std::cout << "Make sure visualization_server is running on localhost:9999\n\n";
            #endif
            «ENDIF»

            // Simulation parameters
            double sim_time = 0.0;
            double dt = 0.01;  // 10ms timestep
            double max_time = 30.0;  // 30 second simulation

            std::cout << "Starting simulation...\n";
            std::cout << "Duration: " << max_time << "s, Timestep: " << dt << "s\n\n";

            // Main timing loop
            while (sim_time < max_time) {
                // Step the physics engine
                «platformName»_step();

                «IF hasVisualization»
                // Update visualization if enabled
                #ifdef HAS_VISUALIZATION
                updateRobotVisualization();
                #endif
                «ENDIF»

                // Stub: D-model cycle (commented out for standalone)
                // #ifdef HAS_DMODEL_INTERFACE
                // dmodel_cycle();
                // #endif

                // Stub: World engine update (commented out for standalone)
                // #ifdef HAS_WORLD_ENGINE
                // world_update();
                // #endif

            // Advance simulation time
            sim_time += dt;

            // Sleep to run in real-time (Wait operator from paper)
            const useconds_t sleep_us = static_cast<useconds_t>(dt * 1e6);
            usleep(sleep_us);

            // Progress indicator every second
            if (static_cast<int>(sim_time) % 1 == 0 && sim_time - dt < static_cast<int>(sim_time)) {
                std::cout << "Simulation time: " << sim_time << "s\r" << std::flush;
            }
        }

            std::cout << "\n\nSimulation complete!\n";
            std::cout << "Final time: " << sim_time << "s\n";

            return 0;
        }
        '''
    }

    /**
     * Generate CMakeLists.txt for STANDALONE and STANDALONE_VISUALISATION modes
     */
    def String generateCMakeLists(Solution solution, String platformName, GenerationMode mode) {
        val hasVisualization = mode == GenerationMode.STANDALONE_VISUALISATION
        val hasOrchestrator = (mode == GenerationMode.STANDALONE || mode == GenerationMode.STANDALONE_VISUALISATION)
        // Use solution name if available, otherwise fall back to platformName_physics
        val projectName = if (solution?.name !== null && !solution.name.isEmpty) {
            solution.name
        } else {
            platformName + "_physics"
        }
        '''
        cmake_minimum_required(VERSION 3.10)
        project(«projectName»)

        # C++17 standard
        set(CMAKE_CXX_STANDARD 17)
        set(CMAKE_CXX_STANDARD_REQUIRED ON)

        # Eigen (header-only): locate headers robustly
        # Allow override via EIGEN3_INCLUDE_DIR env or cache variable
        set(EIGEN3_HINTS $ENV{EIGEN3_INCLUDE_DIR} ${EIGEN3_INCLUDE_DIR})
        find_path(EIGEN3_INCLUDE_DIR Eigen/Dense
            HINTS ${EIGEN3_HINTS}
            PATHS /usr/include/eigen3 /usr/local/include/eigen3
        )
        if(NOT EIGEN3_INCLUDE_DIR)
            message(FATAL_ERROR "Eigen headers not found. Install libeigen3-dev or set EIGEN3_INCLUDE_DIR.")
        endif()
        
        «IF hasVisualization»
        # Find Threads for visualization server
        find_package(Threads REQUIRED)
        
        # Find MeshcatCpp (optional)
        find_package(MeshcatCpp QUIET)
        «ENDIF»

        # Source files for physics simulation
        set(SOURCE_FILES
            src/«platformName»_engine.cpp
            «IF hasOrchestrator»
            src/orchestrator.cpp
            «ENDIF»
        )

        # Physics simulation executable
        add_executable(«platformName»_sim ${SOURCE_FILES})

        # Include directories
        target_include_directories(«platformName»_sim PRIVATE
            ${CMAKE_CURRENT_SOURCE_DIR}/src
            ${EIGEN3_INCLUDE_DIR}
        )

        «IF hasVisualization»
        # Visualization support - define HAS_VISUALIZATION for physics simulation
        target_compile_definitions(«platformName»_sim PRIVATE HAS_VISUALIZATION)
        
        # Separate visualization server executable
        add_executable(visualization_server
            src/visualization_server.cpp
        )
        
        target_include_directories(visualization_server PRIVATE
            ${CMAKE_CURRENT_SOURCE_DIR}/src
            ${EIGEN3_INCLUDE_DIR}
        )
        
        target_link_libraries(visualization_server
            Threads::Threads
            m  # Math library
        )
        
        # Conditionally link MeshcatCpp if found
        if(MeshcatCpp_FOUND)
            target_link_libraries(visualization_server MeshcatCpp::MeshcatCpp)
            target_compile_definitions(visualization_server PRIVATE HAS_MESHCAT=1)
        else()
            message(WARNING "MeshcatCpp not found. Visualization server will use stub implementation.")
            target_compile_definitions(visualization_server PRIVATE HAS_MESHCAT=0)
        endif()
        
        target_compile_options(visualization_server PRIVATE
            -Wall
            -Wextra
            -g
            -O0
        )
        «ENDIF»

        # Compiler warnings
        if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
            target_compile_options(«platformName»_sim PRIVATE -Wall -Wextra -Wpedantic)
        endif()

        # Installation
        install(TARGETS «platformName»_sim
            RUNTIME DESTINATION bin
        )
        
        «IF hasVisualization»
        install(TARGETS visualization_server
            RUNTIME DESTINATION bin
        )
        «ENDIF»
        '''
    }

    /**
     * Generate orchestrator.h header file with API declarations
     */
    def String generateOrchestratorHeader(Solution solution, String platformName, GenerationMode mode) {
        '''
        #ifndef ORCHESTRATOR_H
        #define ORCHESTRATOR_H

        #include <pthread.h>

        /* TODO/STUB */

        typedef struct {
            pthread_t input_thread_id;
            pthread_t output_thread_id;
        } engine_threads_t;

        /* TODO/STUB */
        engine_threads_t start_engine_runtime();

        /* TODO/STUB */
        void shutdown_engine(engine_threads_t engine_threads);

        /* TODO/STUB */
        void Wait(double cycleDurationSeconds);

        #endif // ORCHESTRATOR_H
        '''
    }

    /**
     * Generate orchestrator.cpp with stub methods for user implementation
     *
     * The orchestrator implements the main RoboSim action:
     *   Init; mu X . SendToDModel; ReceiveFromDModel interrupted by Wait(cycle); Evolve; X
     */
    def String generateOrchestrator(Solution solution, String platformName, GenerationMode mode) {
        '''
        /*
         * Orchestrator stub - generated for mode: «mode»
         * This file is intentionally minimal and is replaced by the integration
         * test harness using reference implementations.
         */

        #include <iostream>
        #include "orchestrator.h"
        #include "interfaces.hpp"
        #include "«platformName»_state.hpp"
        #include "platform_mapping.h"
        #include "world_mapping.h"
        #include "utils.h"

        engine_threads_t start_engine_runtime() {
            /* TODO/STUB */
            engine_threads_t threads{};
            return threads;
        }

        void shutdown_engine(engine_threads_t /*threads*/) {
            /* TODO/STUB */
        }

        void Wait(double cycleDurationSeconds) {
            (void)cycleDurationSeconds;
            /* TODO/STUB */
        }

        int main(int argc, char* argv[]) {
            (void)argc;
            (void)argv;
            std::cout << "=== Orchestrator (STUB) ===" << std::endl;
            std::cout << "Generated stub for mode " << "«mode»" << ". Manual implementation required." << std::endl;
            /* TODO/STUB */
            return 0;
        }
        '''
    }

    /**
     * Generate world_mapping.h for STANDALONE_VISUALISATION mode
     * Contains world-level parameters (e.g., gravity) that are synchronized with the platform
     */
    def String generateWorldMappingHeader() {
        '''
        #ifndef WORLD_MAPPING_H
        #define WORLD_MAPPING_H

        #ifdef __cplusplus
        extern "C" {
        #endif

        // World mapping state structure
        // Contains world-level parameters that are synchronized with the platform
        typedef struct {
            double g[3];  // Gravity vector in world coordinates [x, y, z]
        } world_mapping_t;

        // World mapping instance (defined in platform engine)
        extern world_mapping_t w_mapping;

        #ifdef __cplusplus
        }
        #endif

        #endif // WORLD_MAPPING_H
        '''
    }

    /**
     * Generate interfaces.hpp providing the abstraction layer shared between the
     * generated physics engine, orchestrator stub, and manual integration code.
     */
    def String generateInterfacesHeader() {
        '''
#ifndef INTERFACES_HPP
#define INTERFACES_HPP

#include <cstddef>
#include <vector>
#include <string>

#include "dmodel_data.h"

// Forward declarations
struct mapping_state_t;
struct sensor_data_t;

/**
 * Abstract entity state.
 * 
 * Entities are state holders representing physical objects/components.
 * Each entity type defines its own State struct with entity-specific variables.
 * 
 * Examples of entities:
 *   - Platform (robot): joint angles, velocities, link transforms
 *   - Object (block, ball): position, velocity, mass, geometry
 *   - Goal (target marker): position, orientation
 * 
 * Key distinction:
 *   - Entity = State holder (position, mass, etc.)
 *   - Engine = Dynamics simulator (computes how state evolves)
 * 
 * Platform is an entity WITH an engine (has dynamics).
 * Objects are entities WITHOUT engines (passive, no autonomous motion).
 * World is NOT an entity - it's a container of entities.
 */
struct IEntityState {
    virtual ~IEntityState() = default;
};

/**
 * Abstract world state.
 * 
 * World is a CONTAINER of entities (objects, environment, etc.).
 * World state includes:
 *   - Collection of entity states (e.g., positions of all objects)
 *   - Global/environmental properties (gravity, air resistance, etc.)
 * 
 * World is NOT an entity - it's the environment where entities interact.
 */
struct IWorldState {
    virtual ~IWorldState() = default;
};

// Platforms are entities (robots, machines that can be controlled)
using IPlatformState = IEntityState;

// EventData and OperationData are defined in dmodel_data.h

struct IDModelIO {
    virtual ~IDModelIO() = default;
    virtual bool registerRead(int* type, void* data, size_t size) = 0;
    virtual void registerWrite(const OperationData* op) = 0;
    virtual void tock(int type) = 0;
};

/**
 * Abstract operation interface (platform-agnostic).
 * Operations compute actuator outputs as functions of integrated variables (e.g., phase time, velocity, etc.).
 * Concrete implementations are generated from Mapping.pm and defined in platform_mapping.h.
 */
class IOperation {
public:
    virtual ~IOperation() = default;
    
    /** Get operation name (e.g., "PrePick") */
    virtual const char* getName() const = 0;
    
    /** 
     * Compute actuator outputs given current values of integrated variables.
     * Platform-specific mapping struct is passed by reference (defined in platform_mapping.h).
     * The mapping struct contains all integrated variables and sensor readings.
     * 
     * @param mapping Platform mapping struct to read integrated variables from and write actuator outputs to
     * 
     * Note: Integrated variables (those with derivative(var) == constant in Mapping.pm) are stored
     * in the mapping struct and automatically updated by the orchestrator between computeOutputs calls.
     */
    virtual void computeOutputs(mapping_state_t& mapping) const = 0;
    
    /** 
     * Get list of variables with derivative(var) == 1 (or other constant rates).
     * These are automatically integrated by the orchestrator at their specified rates.
     * Returns pairs of (variable_name, derivative_value).
     * 
     * Example: {"k", 1.0} means dk/dt = 1, so the orchestrator will update mapping.k += 1.0 * dt
     */
    virtual std::vector<std::pair<std::string, double>> getIntegratedVariables() const = 0;
};

/**
 * Abstract event interface (platform-agnostic).
 * Events evaluate predicates on sensor measurements.
 * Concrete implementations are generated from Mapping.pm and defined in platform_mapping.h.
 */
class IEvent {
public:
    virtual ~IEvent() = default;
    
    /** Get event name (e.g., "detectObject") */
    virtual const char* getName() const = 0;
    
    /** 
     * Evaluate event predicate on current sensor readings.
     * Platform-specific mapping struct is passed by reference.
     * 
     * @param mapping Platform mapping struct to read sensors from (forward-declared here)
     * @return true if event predicate is satisfied
     */
    virtual bool evaluate(const mapping_state_t& mapping) const = 0;
};

// Abstract interfaces for engines and mappings

/**
 * Entity: Base class for physical objects in the simulation.
 * Contains state, identity, and time management.
 * 
 * Entity = State + Identity + Time
 * Engine = Dynamics (separate, only for platforms)
 * 
 * Examples: Platform, Object, Goal
 */
class Entity {
protected:
    std::string entity_name;
    int entity_id;
    double simulation_time;

public:
    explicit Entity(const std::string& name = "Entity", int id = -1)
        : entity_name(name)
        , entity_id(id)
        , simulation_time(0.0)
    {}

    virtual ~Entity() = default;

    // Identity
    const std::string& getName() const { return entity_name; }
    void setName(const std::string& name) { entity_name = name; }
    int getID() const { return entity_id; }
    void setID(int id) { entity_id = id; }

    // Time management
    double getTime() const { return simulation_time; }
    virtual void advanceTime(double dt) { simulation_time += dt; }
    virtual void resetTime() { simulation_time = 0.0; }

    // State access
    virtual IEntityState& getState() = 0;
    virtual const IEntityState& getState() const = 0;

    // Type identification
    virtual const char* getType() const = 0;

    virtual void printState() const {
        printf("[Entity] %s (ID=%d, type=%s, time=%.3f)\n",
               entity_name.c_str(), entity_id, getType(), simulation_time);
    }
};

/**
 * Platform - controllable robot/machine entity.
 * Extends Entity (like Object, Goal) for consistency.
 * Active entities (platforms) have engines that update their state.
 */
class Platform : public Entity {
public:
    Platform(const std::string& name, int id) : Entity(name, id) {}
    virtual ~Platform() = default;
    
    const char* getType() const override { return "Platform"; }
};

/**
 * Platform engine interface - computes dynamics for a Platform entity.
 */
class IPlatformEngine {
public:
    virtual ~IPlatformEngine() = default;
    virtual void initialise() = 0;
    virtual void update() = 0;
    virtual double getTime() const = 0;
    virtual Platform& getPlatform() = 0;
    virtual const Platform& getPlatform() const = 0;
};

/**
 * Abstract world engine interface.
 * 
 * World is a CONTAINER that manages:
 *   - Multiple entities (objects, environmental elements)
 *   - Inter-entity interactions (collisions, forces, etc.)
 *   - Global physics (gravity, air resistance, lighting, etc.)
 * 
 * World engine orchestrates all world entities and their interactions.
 * Individual entities (like objects) may have their own IEntityEngine instances,
 * or the world engine may manage them directly.
 * 
 * World does NOT directly receive platform data - mappings bridge entities.
 */
class IWorldEngine {
public:
    virtual ~IWorldEngine() = default;
    virtual void initialise() = 0;
    
    /**
     * Advance world physics/dynamics by one time step.
     * 
     * Reads:
     *   - World inputs from mappings (e.g., platform gripper position affects object)
     * 
     * Updates:
     *   - Entity states (object positions, contact forces, etc.)
     *   - Environmental state (lighting, temperature, etc.)
     *   - Inter-entity interactions (collisions, constraints)
     */
    virtual void update() = 0;
    
    virtual double getTime() const = 0;
    virtual const IWorldState& state() const = 0;   // World state (all entities + environment)
    virtual IWorldState& state() = 0;
};

/**
 * Abstract platform-world mapping interface.
 * 
 * Bidirectional mapping between platform and world engines via global coupling variables:
 * 
 *   Platform Engine ←→ Mapping ←→ World Engine
 *        (theta)    →  FK  →  (gripper_pos) → world input
 *    (sensor_data)  ←  IK  ←  (object_pos)  ← world output
 * 
 * The mapping defines EQUATIONS that relate platform variables to world variables:
 *   1. Platform → World: computeWorldInputs()
 *      Example: gripper_world_position = FK(theta_platform)
 *      Sets world engine input globals (like platform engine reads actuator globals)
 * 
 *   2. World → Platform: computeSensorReadings()  
 *      Example: distance_sensor = ||object_pos - gripper_pos||
 *      Reads world state, computes sensor outputs for platform
 * 
 * Both engines are independent - the mapping is the ONLY coupling.
 */
class IPlatformWorldMapping {
public:
    virtual ~IPlatformWorldMapping() = default;
    virtual void initialise() = 0;
    
    /**
     * Compute sensor readings from world state and platform state.
     * 
     * Reads:
     *   - World state (e.g., object positions from world engine)
     *   - Platform state (e.g., joint angles for FK to get sensor locations)
     * 
     * Writes:
     *   - Sensor data (e.g., distance readings, contact forces)
     * 
     * @param world_state World state (cast to concrete type)
     * @param platform_state Platform state (cast to concrete type)
     * @param sensor_output Computed sensor readings
     */
    virtual void computeSensorReadings(
        const IWorldState& world_state,
        const IPlatformState& platform_state,
        sensor_data_t& sensor_output
    ) = 0;
    
    /**
     * Compute world inputs from platform actuator outputs.
     * 
     * Reads:
     *   - Platform state (e.g., joint angles, actuator forces)
     * 
     * Writes:
     *   - World state inputs (e.g., gripper position affects object position)
     *   - These are global variables that world engine reads in its update()
     * 
     * Just like platform engine reads torque commands from globals set by controller,
     * world engine reads position/force commands from globals set by this mapping.
     * 
     * @param platform_state Platform state (cast to concrete type)
     * @param world_state World state to update (cast to concrete type)
     */
    virtual void computeWorldInputs(
        const IPlatformState& platform_state,
        IWorldState& world_state
    ) = 0;
};

/**
 * Abstract platform mapping interface (controller's view).
 * Manages the mapping state (controller's abstraction of platform sensors/actuators).
 * Updated from sensor readings; provides actuator commands to platform engine.
 */
class IPlatformMapping {
public:
    virtual ~IPlatformMapping() = default;
    virtual void initialise() = 0;
    
    /**
     * Access platform mapping state (controller's view of sensors, actuators, etc.).
     * @return Reference to platform-specific mapping struct
     */
    virtual mapping_state_t& mapping() = 0;
    
    /**
     * Update mapping state from sensor_output produced by computeSensorReadings.
     * Includes both world-dependent and platform-internal sensor readings.
     *
     * @param sensor_output Sensor readings from platform-world mapping
     */
    virtual void updateFromSensors(const sensor_data_t& sensor_output) = 0;
};

// Accessors for concrete instances (defined in respective .cpp files)
IPlatformEngine* get_platform_engine();
IWorldEngine* get_world_engine();
IPlatformWorldMapping* get_platform_world_mapping();  // Renamed from IWorldMapping
IPlatformMapping* get_platform_mapping();

// Active D-Model adapter setter used by the C bridge
void set_active_dmodel_io(IDModelIO* io);

#endif // INTERFACES_HPP
        '''
    }

    /**
     * Generate dmodel_data.h providing shared data types for D-model communication.
     * Defines EventData (for registerRead) and OperationData (for registerWrite).
     */
    def String generateDModelDataHeader() {
        '''
#ifndef DMODEL_DATA_H
#define DMODEL_DATA_H

#include <stdbool.h>
#include <stddef.h>

/**
 * Payload for scalar event delivery via registerRead.
 *
 * Encoding:
 *   - Predicate-only events: occurred = predicate value, value = 0.0
 *   - Value-carrying events: occurred = true, value = parameter
 *   - Structured events use dedicated payload structs (e.g., AcrobotSensorState)
 *
 * D-models must read 'occurred' for predicate events; 'value' is only meaningful
 * when occurred == true for value-carrying events.
 */
typedef struct {
    bool occurred;   // Whether the event occurred (or predicate result)
    double value;    // Optional associated value (e.g., sensor reading)
} EventData;

/**
 * Payload for operation commands via registerWrite.
 *
 * D-models write operation commands to the engine using this struct.
 * The engine reads the operation type and parameters to update platform mapping.
 */
#ifndef DMODEL_MAX_OP_PARAMS
#define DMODEL_MAX_OP_PARAMS 4
#endif

typedef struct {
    int type;                  // OUTPUT_* operation type
    size_t param_count;        // Number of parameters in params[]
    double params[DMODEL_MAX_OP_PARAMS]; // Operation parameters (ordered)
    double time;               // Timestamp (if needed)
} OperationData;

#endif // DMODEL_DATA_H
        '''
    }

    def String generateUtilsHeader() {
        '''
#ifndef UTILS_H
#define UTILS_H

#include <Eigen/Dense>
#include <vector>
#include <fstream>

// ============================================================================
// Utilities: Platform diagnostics and logging
// ============================================================================
//
// These functions provide diagnostic logging for platform state variables.
// Implemented in utils.cpp
// ============================================================================

// Shared logging state (defined in utils.cpp)
extern std::ofstream high_freq_log_file;
extern bool high_freq_logging_enabled;
extern int log_counter;
extern const double HIGH_FREQ_LOG_PERIOD;
extern std::ofstream velocity_log_file;
extern bool velocity_logging_enabled;

// Torque logging (controller outputs)
void enable_torque_logging(const char* filename);
void disable_torque_logging(void);
void log_torque(double time, const Eigen::VectorXd& torques);

// High-frequency torque logging (1ms resolution)
void enable_high_freq_logging(const char* filename);
void disable_high_freq_logging(void);
void log_high_freq_torque(double time, const Eigen::VectorXd& torques, double dt);

// Velocity logging (joint velocities)
void enable_velocity_logging(const char* filename);
void disable_velocity_logging(void);
void log_velocity(double time, const Eigen::VectorXd& positions, const Eigen::VectorXd& velocities,
                  const Eigen::VectorXd& torques, const Eigen::MatrixXd& mass_matrix);

// Transform logging (link positions/orientations)
void enable_transform_logging(const char* filename);
void disable_transform_logging(void);
void log_transforms(double time, const std::vector<Eigen::MatrixXd>& frames);

// Mapping debug logging (platform mapping state)
void enable_mapping_debug_logging(const char* filename);
void disable_mapping_debug_logging(void);
void log_mapping_debug(double time, const Eigen::VectorXd& torques, const char* operation, double k);

#endif // UTILS_H
        '''
    }

    def String generateUtilsImpl() {
        '''
// Utility functions: Diagnostic logging for platform state
// Implementation for utils.h

#include "utils.h"
#include <iostream>
#include <fstream>
#include <iomanip>

// Logging state
// Note: torque and transform logging remain file-local (not shared)
namespace {
    std::ofstream torque_log_file;
    bool torque_logging_enabled = false;
}

// Shared logging state (used by platform1_engine.cpp)
std::ofstream high_freq_log_file;
bool high_freq_logging_enabled = false;
int log_counter = 0;
const double HIGH_FREQ_LOG_PERIOD = 0.001;

std::ofstream velocity_log_file;
bool velocity_logging_enabled = false;

namespace {
    
    std::ofstream transform_log_file;
    bool transform_logging_enabled = false;
    
    std::ofstream mapping_debug_log_file;
    bool mapping_debug_logging_enabled = false;
}

// ============================================================================
// Torque Logging
// ============================================================================

void enable_torque_logging(const char* filename) {
    if (torque_log_file.is_open()) torque_log_file.close();
    torque_log_file.open(filename);
    if (torque_log_file.is_open()) {
        torque_log_file << "time,elbow_torque" << std::endl;
        torque_log_file << std::fixed << std::setprecision(6);
        torque_logging_enabled = true;
        std::cout << "[Logging] Torque logging enabled: " << filename << std::endl;
    } else {
        std::cerr << "[Logging] Failed to open torque log file: " << filename << std::endl;
        torque_logging_enabled = false;
    }
}

void disable_torque_logging(void) {
    if (torque_log_file.is_open()) torque_log_file.close();
    torque_logging_enabled = false;
    std::cout << "[Logging] Torque logging disabled" << std::endl;
}

void log_torque(double time, const Eigen::VectorXd& torques) {
    if (torque_logging_enabled && torque_log_file.is_open() && torques.size() >= 2) {
        torque_log_file << time << "," << torques(1) << std::endl;
    }
}

// ============================================================================
// High-Frequency Torque Logging
// ============================================================================

void enable_high_freq_logging(const char* filename) {
    if (high_freq_log_file.is_open()) high_freq_log_file.close();
    high_freq_log_file.open(filename);
    if (high_freq_log_file.is_open()) {
        high_freq_log_file << "time,elbow_torque" << std::endl;
        high_freq_log_file << std::fixed << std::setprecision(6);
        high_freq_logging_enabled = true;
        log_counter = 0;
        std::cout << "[Logging] High-frequency logging enabled: " << filename << " (1ms period)" << std::endl;
    } else {
        std::cerr << "[Logging] Failed to open high-freq log file: " << filename << std::endl;
        high_freq_logging_enabled = false;
    }
}

void disable_high_freq_logging(void) {
    if (high_freq_log_file.is_open()) {
        high_freq_log_file.close();
        std::cout << "[Logging] Torque data saved (high-frequency)" << std::endl;
    }
    high_freq_logging_enabled = false;
    std::cout << "[Logging] High-frequency logging disabled" << std::endl;
}

void log_high_freq_torque(double time, const Eigen::VectorXd& torques, double dt) {
    if (high_freq_logging_enabled && high_freq_log_file.is_open() && torques.size() >= 2) {
        int log_interval = (int)(HIGH_FREQ_LOG_PERIOD / dt);
        if (log_interval < 1) log_interval = 1;
        
        if (log_counter % log_interval == 0) {
            high_freq_log_file << std::fixed << std::setprecision(6) << time;
            high_freq_log_file << "," << std::fixed << std::setprecision(6) << torques(1);
            high_freq_log_file << std::endl;
            high_freq_log_file.flush();
        }
        log_counter++;
    }
}

// ============================================================================
// Velocity Logging
// ============================================================================

void enable_velocity_logging(const char* filename) {
    if (velocity_log_file.is_open()) velocity_log_file.close();
    velocity_log_file.open(filename);
    if (velocity_log_file.is_open()) {
        velocity_log_file << "time,wrist_pos,wrist_vel,elbow_pos,elbow_vel,wrist_tau,elbow_tau,M11_wrist,M22_elbow" << std::endl;
        velocity_log_file << std::fixed << std::setprecision(6);
        velocity_logging_enabled = true;
        std::cout << "[Logging] Velocity logging enabled: " << filename << std::endl;
    } else {
        std::cerr << "[Logging] Failed to open velocity log file: " << filename << std::endl;
        velocity_logging_enabled = false;
    }
}

void disable_velocity_logging(void) {
    if (velocity_log_file.is_open()) {
        velocity_log_file.close();
        std::cout << "[Logging] Velocity data saved" << std::endl;
    }
    velocity_logging_enabled = false;
    std::cout << "[Logging] Velocity logging disabled" << std::endl;
}

void log_velocity(double time, const Eigen::VectorXd& positions, const Eigen::VectorXd& velocities, 
                  const Eigen::VectorXd& torques, const Eigen::MatrixXd& mass_matrix) {
    if (velocity_logging_enabled && velocity_log_file.is_open() && 
        positions.size() >= 2 && velocities.size() >= 2 && torques.size() >= 2) {
        velocity_log_file << std::fixed << std::setprecision(6) << time
                          << "," << positions(0)
                          << "," << velocities(0)
                          << "," << positions(1)
                          << "," << velocities(1)
                          << "," << torques(0)
                          << "," << torques(1);

        double m11 = (mass_matrix.rows() > 0 && mass_matrix.cols() > 0) ? mass_matrix(0,0) : 0.0;
        double m22 = (mass_matrix.rows() > 1 && mass_matrix.cols() > 1) ? mass_matrix(1,1) : 0.0;
        velocity_log_file << "," << std::fixed << std::setprecision(6) << m11
                          << "," << std::fixed << std::setprecision(6) << m22
                          << std::endl;
        velocity_log_file.flush();
    }
}

// ============================================================================
// Transform Logging
// ============================================================================

void enable_transform_logging(const char* filename) {
    if (transform_log_file.is_open()) transform_log_file.close();
    transform_log_file.open(filename);
    if (transform_log_file.is_open()) {
        transform_log_file << "time,";
        auto header_mat = [&](const char* name){
            for (int r = 0; r < 4; ++r) {
                for (int c = 0; c < 4; ++c) {
                    transform_log_file << name << "_" << r << c;
                    if (!(r == 3 && c == 3)) transform_log_file << ",";
                }
            }
        };
        header_mat("Bk2"); transform_log_file << ",";
        header_mat("Bk1"); transform_log_file << ",";
        header_mat("Bk0"); transform_log_file << std::endl;
        transform_logging_enabled = true;
        std::cout << "[Logging] Transform logging enabled: " << filename << std::endl;
    } else {
        std::cerr << "[Logging] Failed to open transform log file: " << filename << std::endl;
        transform_logging_enabled = false;
    }
}

void disable_transform_logging(void) {
    if (transform_log_file.is_open()) {
        transform_log_file.close();
        std::cout << "[Logging] Transform data saved" << std::endl;
    }
    transform_logging_enabled = false;
}

void log_transforms(double time, const std::vector<Eigen::MatrixXd>& frames) {
    if (transform_logging_enabled && transform_log_file.is_open() && frames.size() >= 3) {
        auto write_mat = [](std::ofstream& out, const Eigen::Matrix4d& M){
            out
                << M(0,0) << "," << M(0,1) << "," << M(0,2) << "," << M(0,3) << ","
                << M(1,0) << "," << M(1,1) << "," << M(1,2) << "," << M(1,3) << ","
                << M(2,0) << "," << M(2,1) << "," << M(2,2) << "," << M(2,3) << ","
                << M(3,0) << "," << M(3,1) << "," << M(3,2) << "," << M(3,3);
        };
        transform_log_file << std::fixed << std::setprecision(6) << time << ",";
        write_mat(transform_log_file, frames[2]); transform_log_file << ",";
        write_mat(transform_log_file, frames[1]); transform_log_file << ",";
        write_mat(transform_log_file, frames[0]); transform_log_file << std::endl;
    }
}

// ============================================================================
// Mapping Debug Logging
// ============================================================================

void enable_mapping_debug_logging(const char* filename) {
    if (mapping_debug_log_file.is_open()) mapping_debug_log_file.close();
    mapping_debug_log_file.open(filename);
    if (mapping_debug_log_file.is_open()) {
        mapping_debug_log_file << "time,elbow_torque,operation,k_seconds" << std::endl;
        mapping_debug_log_file.flush();
        mapping_debug_logging_enabled = true;
        std::cout << "[Logging] Mapping debug logging enabled: " << filename << std::endl;
    } else {
        std::cerr << "[Logging] Failed to open mapping debug log file: " << filename << std::endl;
        mapping_debug_logging_enabled = false;
    }
}

void disable_mapping_debug_logging(void) {
    if (mapping_debug_log_file.is_open()) {
        mapping_debug_log_file.close();
        std::cout << "[Logging] Mapping debug data saved" << std::endl;
    }
    mapping_debug_logging_enabled = false;
}

void log_mapping_debug(double time, const Eigen::VectorXd& torques, const char* operation, double k) {
    if (mapping_debug_logging_enabled && mapping_debug_log_file.is_open() && torques.size() >= 2) {
        mapping_debug_log_file << std::fixed << std::setprecision(6)
                               << time << "," << torques(1) << ","
                               << (operation ? operation : "")
                               << "," << k
                               << std::endl;
        mapping_debug_log_file.flush();
    }
}
        '''
    }

    /**
     * Generate platform_mapping_adapter.cpp with sensor copy statements
     * derived from the SensorOutputMapping constraints in the user's mapping specification.
     */
    def String generatePlatformMappingAdapter(Solution solution, String platformName) {
        // Collect all sensor output paths from the registry populated by SensorOutputMapping
        val allSensorPaths = new java.util.LinkedHashSet<String>()
        val registry = SKO.SensorOutputMapping.getSensorPaths()
        for (entry : registry.entrySet) {
            for (sensorEntry : entry.value.entrySet) {
                val path = sensorEntry.key
                if (path.startsWith("p_mapping.")) {
                    allSensorPaths.add(path)
                }
            }
        }

        // Convert p_mapping paths to C++ struct access paths.
        // The registry paths already use dots for struct access
        // (e.g. "p_mapping.Turtlebot3_Burger.BaseLink.TBLidar.scan.range_min").
        // Only the platform name component (first segment after "p_mapping.")
        // may contain underscores that represent nested struct levels
        // (e.g. Turtlebot3_Burger -> Turtlebot3.Burger).
        // Field-level underscores like range_min must be preserved.
        val sensorCopyStatements = new java.util.ArrayList<String>()
        for (path : allSensorPaths) {
            val withoutPrefix = path.substring("p_mapping.".length)
            // Split into segments: first segment is the platform name, rest are struct fields
            val firstDot = withoutPrefix.indexOf('.')
            val structPath = if (firstDot > 0) {
                val platformSegment = withoutPrefix.substring(0, firstDot)
                val rest = withoutPrefix.substring(firstDot)  // includes leading dot
                // Only replace underscores in the platform name segment
                platformSegment.replace("_", ".") + rest
            } else {
                // No dots after platform name — just replace underscores in the whole thing
                withoutPrefix.replace("_", ".")
            }
            sensorCopyStatements.add(
                "        p_mapping." + structPath + " =\n" +
                "            sensor_output." + structPath + ";"
            )
        }

        val sensorBody = if (sensorCopyStatements.isEmpty) {
            '''
        // Sensor outputs - copied from sensor_output
        (void)sensor_output;
        // No SensorOutputMapping constraints were provided for this model.
        // Keep this adapter as a no-op to avoid assuming fixture-specific sensor structs.'''
        } else {
            '''
        // Sensor outputs - auto-generated from SensorOutputMapping constraints
        «sensorCopyStatements.join("\n")»'''
        }

        '''
#include "interfaces.hpp"
#include "platform_mapping.h"  // Has proper extern "C" guards internally

extern mapping_state_t w_mapping;
extern "C" mapping_state_t p_mapping;

namespace {
class PlatformMappingImpl final : public IPlatformMapping {
public:
    void initialise() override {
        // No world snapshot mirroring; mapping is updated from sensors explicitly
    }

    mapping_state_t& mapping() override {
        return p_mapping;
    }

    void updateFromSensors(const sensor_data_t& sensor_output) override {
        // Copy world-level sensor outputs into mapping.
        // sensor_data_t includes both world-dependent and platform-internal sensors.
        p_mapping.World.gravity_world[0] = sensor_output.World.gravity_world[0];
        p_mapping.World.gravity_world[1] = sensor_output.World.gravity_world[1];
        p_mapping.World.gravity_world[2] = sensor_output.World.gravity_world[2];

«sensorBody»
    }
};

PlatformMappingImpl platform_mapping_instance;
} // namespace

IPlatformMapping* get_platform_mapping() {
    return &platform_mapping_instance;
}
        '''
    }
    /**
     * Extract the number of degrees of freedom from the solution.
     * Heuristic: look for theta vector dimension in state variables.
     */
    def int extractNumDofs(Solution solution) {
        // Default to 2 DOFs (typical for 2-link robots like Acrobot)
        if (solution?.state?.variables === null) {
            return 2
        }
        
        for (varLine : solution.state.variables) {
            val varName = varLine?.variable?.name
            val varType = varLine?.variable?.type
            if (varName == "theta" && varType !== null) {
                // Try to extract dimension from type like VectorType
                // The type structure is complex, so we default to 2 for now
                // This could be enhanced to properly parse VectorType dimensions
            }
        }
        
        return 2  // Default
    }
    
    /**
     * Extract the actual platform name from the solution (e.g., "AcrobotControlled").
     * Extracts from p_mapping state variables which have the form
     * p_mapping_<PlatformName>_<Link>_<Sensor>_<Field>.
     * Also handles constraints with dot-notation like p_mapping.PlatformName.Link.Sensor.Field.
     */
    def String extractActualPlatformName(Solution solution) {
        // First, try to extract from p_mapping state variables
        // These have the form: p_mapping_<PlatformName>_<Link>_<Sensor>_<Field>
        if (solution?.state?.variables !== null) {
            for (varLine : solution.state.variables) {
                val varName = varLine?.variable?.name
                if (varName !== null && varName.startsWith("p_mapping_")) {
                    // Extract first component after p_mapping_
                    val withoutPrefix = varName.substring("p_mapping_".length)
                    val firstUnderscore = withoutPrefix.indexOf('_')
                    if (firstUnderscore > 0) {
                        return withoutPrefix.substring(0, firstUnderscore)
                    } else if (!withoutPrefix.isEmpty) {
                        return withoutPrefix
                    }
                }
            }
        }

        // Second, try to extract from computation statements with dot-notation
        // These have the form: variable = p_mapping.PlatformName.Link.Sensor.Field
        if (solution?.computation?.lines !== null) {
            for (stmt : solution.computation.lines) {
                val stmtText = stmt?.toString ?: ""
                // Look for p_mapping.PlatformName pattern
                val pmappingPrefix = "p_mapping."
                if (stmtText.contains(pmappingPrefix)) {
                    val startIdx = stmtText.indexOf(pmappingPrefix)
                    if (startIdx >= 0) {
                        val afterPrefix = stmtText.substring(startIdx + pmappingPrefix.length)
                        val nextDot = afterPrefix.indexOf('.')
                        if (nextDot > 0) {
                            return afterPrefix.substring(0, nextDot)
                        }
                    }
                }
            }
        }

        // Third, fallback to extracting from solution name if it contains an expected pattern
        val solutionName = solution?.name
        if (solutionName !== null && !solutionName.isEmpty()) {
            // Solution name might be something like "AcrobotControlled_physics"
            // Extract the first part before underscore as platform name
            val underscoreIdx = solutionName.indexOf('_')
            if (underscoreIdx > 0) {
                return solutionName.substring(0, underscoreIdx)
            }
            return solutionName
        }

        throw new IllegalStateException("Cannot extract platform name: no p_mapping_* state variables found in solution")
    }

    /**
     * Generate visualization_client.h header for client-side visualization support
     */
    def String generateVisualizationClientHeader() {
        '''
        // visualization_client.h - Client interface for sending visualization data
        #ifndef VISUALIZATION_CLIENT_H
        #define VISUALIZATION_CLIENT_H

        #include <Eigen/Dense>
        #include <string>
        #include <cstring>
        #include <sys/socket.h>
        #include <netinet/in.h>
        #include <arpa/inet.h>
        #include <unistd.h>

        // Message types for IPC
        enum MessageType {
            MSG_ROBOT_TRANSFORM = 1,
            MSG_WORLD_OBJECT = 2,
            MSG_INITIALIZE = 3,
            MSG_SHUTDOWN = 4
        };

        // Transform data structure
        struct TransformData {
            MessageType type;
            char object_name[32];
            double transform[16];  // 4x4 matrix in column-major order
        };

        // Object creation data
        struct ObjectData {
            MessageType type;
            char object_name[32];
            int shape_type;  // 0=box, 1=cylinder, 2=sphere, 3=mesh
            double dimensions[3];
            int color[3];
            char mesh_path[256];  // Path for shape_type=3
        };

        class VisualizationClient {
        private:
            int socket_;
            struct sockaddr_in server_addr_;
            bool connected_;
            
        public:
            VisualizationClient() : socket_(-1), connected_(false) {
                memset(&server_addr_, 0, sizeof(server_addr_));
            }
            
            ~VisualizationClient() {
                disconnect();
            }
            
            bool connect(const char* server_ip = "127.0.0.1", int port = 9999) {
                socket_ = socket(AF_INET, SOCK_DGRAM, 0);
                if (socket_ < 0) {
                    return false;
                }
                
                server_addr_.sin_family = AF_INET;
                server_addr_.sin_port = htons(port);
                inet_pton(AF_INET, server_ip, &server_addr_.sin_addr);
                
                connected_ = true;
                return true;
            }
            
            void disconnect() {
                if (socket_ >= 0) {
                    close(socket_);
                    socket_ = -1;
                }
                connected_ = false;
            }
            
            bool sendTransform(const std::string& object_name, const Eigen::Matrix4d& transform, bool is_world = false) {
                if (!connected_) return false;
                
                TransformData data;
                data.type = is_world ? MSG_WORLD_OBJECT : MSG_ROBOT_TRANSFORM;
                strncpy(data.object_name, object_name.c_str(), sizeof(data.object_name) - 1);
                data.object_name[sizeof(data.object_name) - 1] = '\0';
                
                // Convert Eigen matrix to column-major array
                for (int j = 0; j < 4; ++j) {
                    for (int i = 0; i < 4; ++i) {
                        data.transform[j * 4 + i] = transform(i, j);
                    }
                }
                
                int sent = sendto(socket_, &data, sizeof(data), 0,
                                 (struct sockaddr*)&server_addr_, sizeof(server_addr_));
                return sent == sizeof(data);
            }
            
            bool createObject(const std::string& object_name, int shape_type, 
                             const double dims[3], const int color[3]) {
                if (!connected_) return false;
                
                ObjectData data;
                std::memset(&data, 0, sizeof(data));
                data.type = MSG_INITIALIZE;
                strncpy(data.object_name, object_name.c_str(), sizeof(data.object_name) - 1);
                data.object_name[sizeof(data.object_name) - 1] = '\0';
                data.shape_type = shape_type;
                memcpy(data.dimensions, dims, sizeof(data.dimensions));
                memcpy(data.color, color, sizeof(data.color));
                data.mesh_path[0] = '\0';
                
                int sent = sendto(socket_, &data, sizeof(data), 0,
                             (struct sockaddr*)&server_addr_, sizeof(server_addr_));
                return sent == sizeof(data);
            }

            // Create a mesh object
            bool createMesh(const std::string& object_name, const std::string& mesh_path,
                            double scale, const int color[3]) {
                if (!connected_) return false;

                ObjectData data;
                std::memset(&data, 0, sizeof(data));
                data.type = MSG_INITIALIZE;
                strncpy(data.object_name, object_name.c_str(), sizeof(data.object_name) - 1);
                data.object_name[sizeof(data.object_name) - 1] = '\0';
                data.shape_type = 3;  // mesh
                data.dimensions[0] = scale;
                data.dimensions[1] = 1.0;
                data.dimensions[2] = 1.0;
                memcpy(data.color, color, sizeof(data.color));
                strncpy(data.mesh_path, mesh_path.c_str(), sizeof(data.mesh_path) - 1);
                data.mesh_path[sizeof(data.mesh_path) - 1] = '\0';

                int sent = sendto(socket_, &data, sizeof(data), 0,
                                 (struct sockaddr*)&server_addr_, sizeof(server_addr_));
                return sent == sizeof(data);
            }
            
            bool sendShutdown() {
                if (!connected_) return false;
                
                MessageType type = MSG_SHUTDOWN;
                int sent = sendto(socket_, &type, sizeof(type), 0,
                                 (struct sockaddr*)&server_addr_, sizeof(server_addr_));
                return sent == sizeof(type);
            }
            
            bool isConnected() const {
                return connected_;
            }
        };

        // C interface for easier integration
        extern "C" {
            // Initialize visualization client
            int viz_client_connect(const char* server_ip, int port);
            
            // Send transform update
            int viz_client_send_transform(const char* object_name, const double* transform_4x4, int is_world);
            
            // Disconnect
            void viz_client_disconnect();
        }

        #endif // VISUALIZATION_CLIENT_H
        '''
    }

    /**
     * Generate visualization_server.cpp for running the visualization server
     */
    def String generateVisualizationServer() {
        '''
        // visualization_server.cpp - Unified visualization server for robot and world
        #include <iostream>
        #include <Eigen/Dense>
        #include <thread>
        #include <chrono>
        #include <atomic>
        #include <memory>
        #include <mutex>
        #include <cstring>
        #include <sys/socket.h>
        #include <netinet/in.h>
        #include <unistd.h>
        #include <signal.h>
        #include <errno.h>

        #if (defined(HAS_MESHCAT) && HAS_MESHCAT) || (defined(HAVE_MESHCAT) && HAVE_MESHCAT)
        #include <MeshcatCpp/Material.h>
        #include <MeshcatCpp/Meshcat.h>
        #include <MeshcatCpp/Shape.h>
        #else
        #error "MeshcatCpp must be available for FULL_SIMULATION_VISUALISATION builds"
        #endif

        // Message types for IPC
        enum MessageType {
            MSG_ROBOT_TRANSFORM = 1,
            MSG_WORLD_OBJECT = 2,
            MSG_INITIALIZE = 3,
            MSG_SHUTDOWN = 4
        };

        // Transform data structure
        struct TransformData {
            MessageType type;
            char object_name[32];
            double transform[16];  // 4x4 matrix in column-major order
        };

        // Object creation data
        struct ObjectData {
            MessageType type;
            char object_name[32];
            int shape_type;  // 0=box, 1=cylinder, 2=sphere, 3=mesh
            double dimensions[3];
            int color[3];
            char mesh_path[256];  // Mesh path for shape_type=3
        };

        class VisualizationServer {
        private:
        #ifdef HAS_MESHCAT
            std::unique_ptr<MeshcatCpp::Meshcat> meshcat_;
        #else
            void* meshcat_;  // Placeholder when MeshcatCpp not available
        #endif
            std::mutex meshcat_mutex_;
            std::atomic<bool> running_;
            int server_socket_;
            std::thread receive_thread_;
            
        public:
            VisualizationServer() : running_(false), server_socket_(-1) {}
            
            ~VisualizationServer() {
                stop();
            }
            
            bool start(int port = 9999) {
        #ifdef HAS_MESHCAT
                // Initialize Meshcat
                meshcat_ = std::make_unique<MeshcatCpp::Meshcat>();
                std::cout << "[VisualizationServer] Meshcat started. Check console output above for the actual port (usually 7000-7099)" << std::endl;
        #else
                meshcat_ = nullptr;
                std::cout << "[VisualizationServer] MeshcatCpp not available - visualization server running in stub mode" << std::endl;
        #endif
                
                // Initialize socket server for receiving data (always enabled, even without Meshcat)
                server_socket_ = socket(AF_INET, SOCK_DGRAM, 0);
                if (server_socket_ < 0) {
                    std::cerr << "[VisualizationServer] Failed to create socket" << std::endl;
                    return false;
                }
                
                // Allow socket reuse
                int opt = 1;
                if (setsockopt(server_socket_, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt)) < 0) {
                    std::cerr << "[VisualizationServer] Failed to set socket options" << std::endl;
                    close(server_socket_);
                    return false;
                }
                
                // Set socket timeout to allow clean shutdown
                struct timeval timeout;
                timeout.tv_sec = 1;  // 1 second timeout
                timeout.tv_usec = 0;
                if (setsockopt(server_socket_, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout)) < 0) {
                    std::cerr << "[VisualizationServer] Failed to set socket timeout" << std::endl;
                    close(server_socket_);
                    return false;
                }
                
                struct sockaddr_in server_addr;
                memset(&server_addr, 0, sizeof(server_addr));
                server_addr.sin_family = AF_INET;
                server_addr.sin_addr.s_addr = INADDR_ANY;
                server_addr.sin_port = htons(port);
                
                if (bind(server_socket_, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0) {
                    std::cerr << "[VisualizationServer] Failed to bind socket to port " << port << std::endl;
                    close(server_socket_);
                    return false;
                }
                
                // Initialize scene objects
                initializeScene();
                
                // Start receive thread
                running_ = true;
                receive_thread_ = std::thread(&VisualizationServer::receiveLoop, this);
                
                std::cout << "[VisualizationServer] Listening for visualization data on port " << port << std::endl;
                return true;
            }
            
            void stop() {
                running_ = false;
                if (server_socket_ >= 0) {
                    close(server_socket_);
                    server_socket_ = -1;
                }
                if (receive_thread_.joinable()) {
                    receive_thread_.join();
                }
        #ifdef HAS_MESHCAT
                meshcat_.reset();
        #else
                meshcat_ = nullptr;
        #endif
            }
            
        private:
            void initializeScene() {
        #ifdef HAS_MESHCAT
                std::lock_guard<std::mutex> lock(meshcat_mutex_);
                // Example-agnostic scene setup: only ground plane here.
                // Model-specific geometries are created by clients via MSG_INITIALIZE.
                // Create ground plane for reference
                MeshcatCpp::Material ground_material;
                ground_material.set_color(200, 200, 200);
                ground_material.opacity = 0.5;
                meshcat_->set_object("ground", MeshcatCpp::Box(10.0, 10.0, 0.01), ground_material);
                
                // Set initial transforms
                Eigen::Matrix4d ground_tf = Eigen::Matrix4d::Identity();
                ground_tf(2, 3) = -0.005;  // Slightly below z=0
                meshcat_->set_transform("ground", ground_tf);
        #endif
            }
            
            void receiveLoop() {
                char buffer[1024];
                struct sockaddr_in client_addr;
                socklen_t client_len = sizeof(client_addr);
                
                while (running_) {
                    int bytes = recvfrom(server_socket_, buffer, sizeof(buffer), 0,
                                        (struct sockaddr*)&client_addr, &client_len);
                    
                    if (bytes > 0) {
                        processMessage(buffer, bytes);
                    } else if (bytes < 0) {
                        // Check if it's a timeout (EAGAIN/EWOULDBLOCK) - this is normal
                        if (errno == EAGAIN || errno == EWOULDBLOCK) {
                            // Timeout occurred, continue loop to check running_ flag
                            continue;
                        } else {
                            // Real error occurred
                            if (running_) {
                                std::cerr << "[VisualizationServer] Socket error: " << strerror(errno) << std::endl;
                            }
                            break;
                        }
                    }
                }
            }
            
            void processMessage(const char* buffer, int size) {
        #ifdef HAS_MESHCAT
                if (size < static_cast<int>(sizeof(MessageType))) return;
                
                MessageType type = *reinterpret_cast<const MessageType*>(buffer);
                
                switch (type) {
                    case MSG_ROBOT_TRANSFORM:
                    case MSG_WORLD_OBJECT: {
                        if (size >= static_cast<int>(sizeof(TransformData))) {
                            const TransformData* data = reinterpret_cast<const TransformData*>(buffer);
                            updateTransform(data);
                        }
                        break;
                    }
                    case MSG_INITIALIZE: {
                        if (size >= static_cast<int>(sizeof(ObjectData))) {
                            const ObjectData* data = reinterpret_cast<const ObjectData*>(buffer);
                            createObject(data);
                        }
                        break;
                    }
                    case MSG_SHUTDOWN: {
                        std::cout << "[VisualizationServer] Received shutdown signal" << std::endl;
                        running_ = false;
                        break;
                    }
                }
        #endif
            }
            
            void updateTransform(const TransformData* data) {
        #ifdef HAS_MESHCAT
                std::lock_guard<std::mutex> lock(meshcat_mutex_);
                
                // Convert transform array to Eigen matrix
                Eigen::Matrix4d transform;
                for (int i = 0; i < 4; ++i) {
                    for (int j = 0; j < 4; ++j) {
                        transform(i, j) = data->transform[j * 4 + i];  // Column-major
                    }
                }
                
                meshcat_->set_transform(data->object_name, transform);
        #endif
            }
            
            void createObject(const ObjectData* data) {
        #ifdef HAS_MESHCAT
                std::lock_guard<std::mutex> lock(meshcat_mutex_);
                
                MeshcatCpp::Material material;
                material.set_color(data->color[0], data->color[1], data->color[2]);
                
                switch (data->shape_type) {
                    case 0:  // Box
                        meshcat_->set_object(data->object_name, 
                            MeshcatCpp::Box(data->dimensions[0], data->dimensions[1], data->dimensions[2]), 
                            material);
                        break;
                    case 1:  // Cylinder
                        meshcat_->set_object(data->object_name,
                            MeshcatCpp::Cylinder(data->dimensions[0], data->dimensions[1]),
                            material);
                        break;
                    case 2:  // Sphere
                        meshcat_->set_object(data->object_name,
                            MeshcatCpp::Sphere(data->dimensions[0]),
                            material);
                        break;
                    case 3:  // Mesh
                        {
                            const std::string mesh_path = data->mesh_path;
                            double scale = data->dimensions[0];
                            try {
                                MeshcatCpp::Mesh mesh_obj(mesh_path, scale);
                                meshcat_->set_object(data->object_name, mesh_obj, material);
                                std::cout << "[VisualizationServer] Loaded mesh: " << mesh_path
                                          << " for object: " << data->object_name
                                          << " with scale: " << scale << std::endl;
                            } catch (const std::exception& e) {
                                std::cerr << "[VisualizationServer] Failed to load mesh '" << mesh_path
                                          << "': " << e.what() << ". Falling back to box." << std::endl;
                                meshcat_->set_object(data->object_name,
                                    MeshcatCpp::Box(0.1, 0.1, 0.1), material);
                            }
                        }
                        break;
                }
        #endif
            }
        };

        // Signal handler for clean shutdown
        std::atomic<bool> shutdown_requested(false);

        void signal_handler(int sig) {
            if (sig == SIGINT || sig == SIGTERM) {
                shutdown_requested = true;
            }
        }

        int main(int argc, char* argv[]) {
            // Set up signal handlers
            signal(SIGINT, signal_handler);
            signal(SIGTERM, signal_handler);
            
            int port = 9999;
            if (argc > 1) {
                port = std::atoi(argv[1]);
            }
            
            std::cout << "[VisualizationServer] Starting unified visualization server..." << std::endl;
            
            VisualizationServer server;
            if (!server.start(port)) {
                std::cerr << "[VisualizationServer] Failed to start server" << std::endl;
                return 1;
            }
            
            std::cout << "[VisualizationServer] Server running. Press Ctrl+C to stop." << std::endl;
            
            // Keep running until shutdown is requested
            while (!shutdown_requested) {
                std::this_thread::sleep_for(std::chrono::milliseconds(100));
            }
            
            std::cout << "[VisualizationServer] Shutting down..." << std::endl;
            server.stop();
            
            return 0;
        }
        '''
    }
}
