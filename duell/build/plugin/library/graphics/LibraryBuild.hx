/**
 * @autor rcam
 * @date 18Librarty.08.2014.
 * @company Gameduell GmbH
 */

package duell.build.plugin.library.graphics;

import duell.build.objects.Configuration;

import duell.objects.DuellLib;
import duell.helpers.TemplateHelper;

import haxe.io.Path;


class LibraryBuild
{
    public function new ()
    {}

	public function postParse() : Void
	{
		if (Configuration.getData().LIBRARY.GRAPHICS == null)
		{
			Configuration.getData().LIBRARY.GRAPHICS = LibraryConfiguration.getData();
		}
	}
	
	public function preBuild() : Void
	{
        var libPath : String = DuellLib.getDuellLib("graphics").getPath();

        var exportPath : String = Path.join([Configuration.getData().OUTPUT,"haxe","graphics"]);

        var classSourcePath : String = Path.join([libPath,"template","graphics"]);

        TemplateHelper.recursiveCopyTemplatedFiles(classSourcePath, exportPath, Configuration.getData(), Configuration.getData().TEMPLATE_FUNCTIONS);
	}
	
	public function postBuild() : Void
	{}
}