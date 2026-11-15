package circus.robocalc.robosim.physmod.generator.sourceCodeGen.tests;

import java.util.concurrent.TimeUnit;

/** Stops a started process after a time limit, so tests need no external timeout command. */
public final class ProcessLimit {

    private ProcessLimit() {
    }

    public static void stopAfter(Process process, long seconds) {
        Thread watchdog = new Thread(() -> {
            try {
                if (!process.waitFor(seconds, TimeUnit.SECONDS)) {
                    process.destroy();
                }
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        });
        watchdog.setDaemon(true);
        watchdog.start();
    }
}
