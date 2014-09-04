/**
 * @autor rcam
 * @date 18.08.2014.
 * @company Gameduell GmbH
 */
package duell.build.plugin.library.graphics;

import haxe.io.Path;

typedef KeyValueArray = Array<{NAME : String, VALUE : String}>;


typedef LibraryConfigurationData = {
	DEPTH_TEST : Bool
}

class LibraryConfiguration
{
	public static var _configuration : LibraryConfigurationData = null;
	private static var _parsingDefines : Array<String> = ["graphics"];
	public static function getData() : LibraryConfigurationData
	{
		if (_configuration == null)
			initConfig();
		return _configuration;
	}

	public static function getConfigParsingDefines() : Array<String>
	{
		return _parsingDefines;
	}

	public static function addParsingDefine(str : String)
	{
		_parsingDefines.push(str);
	}

	private static function initConfig()
	{
		_configuration = 
		{
			DEPTH_TEST : true
		};

	}
}