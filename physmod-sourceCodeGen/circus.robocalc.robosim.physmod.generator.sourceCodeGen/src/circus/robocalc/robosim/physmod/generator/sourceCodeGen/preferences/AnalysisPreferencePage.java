package circus.robocalc.robosim.physmod.generator.sourceCodeGen.preferences;

import org.eclipse.jface.preference.DirectoryFieldEditor;
import org.eclipse.jface.preference.FieldEditorPreferencePage;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPreferencePage;

import circus.robocalc.robochart.textual.ui.internal.TextualActivator;

public class AnalysisPreferencePage extends FieldEditorPreferencePage implements IWorkbenchPreferencePage {
	DirectoryFieldEditor sourceCodeGen_path;
    public AnalysisPreferencePage() {
        super(GRID);
    }

    public void createFieldEditors() {
    	sourceCodeGen_path = new DirectoryFieldEditor("sourceCodeGen_PATH", "&sourceCodeGen directory:", getFieldEditorParent());
        addField(sourceCodeGen_path);
        //addField(new BooleanFieldEditor("BOOLEAN_VALUE", "&A boolean preference", getFieldEditorParent()));

        //addField(new RadioGroupFieldEditor("CHOICE", "A &multiple-choice preference", 1,
        //        new String[][] { { "&Choice 1", "choice1" }, { "C&hoice 2", "choice2" } }, getFieldEditorParent()));
        //addField(new StringFieldEditor("MySTRING1", "A &text preference:", getFieldEditorParent()));
        //addField(new StringFieldEditor("MySTRING2", "A t&ext preference:", getFieldEditorParent()));
    }

    @Override
    public void init(IWorkbench workbench) {
        // second parameter is typically the plug-in id
    	setPreferenceStore(TextualActivator.getInstance().getPreferenceStore());
        //setPreferenceStore(new PreferenceStore("robotool.preferences"));
        setDescription("Preferences for supported analysis tools");
    }
}
