/**
 * @autor rcam
 * @date 18Librarty.08.2014.
 * @company Gameduell GmbH
 */

package duell.build.plugin.library.graphics;

/*
import duell.build.objects.DuellProjectXML;
import duell.build.objects.Configuration;
import duell.build.helpers.TemplateHelper;
import duell.build.helpers.XCodeHelper;

import duell.helpers.PathHelper;
import duell.helpers.LogHelper;
import duell.helpers.FileHelper;
import duell.helpers.ProcessHelper;

import duell.objects.DuellLib;
import duell.objects.Haxelib;

import sys.FileSystem;
import haxe.io.Path;
*/

class LibraryBuild
{
    public function new ()
    {
        trace("Initialize Graphics Library Plugin");
    }

	public function postParse() : Void
	{
        trace("PostParse in Graphics");
	}
	
	public function preBuild() : Void
	{
        trace("PreBuild in Graphics");
	}
	
	public function postBuild() : Void
	{
        trace("PostBuild in Graphics");
	}
}