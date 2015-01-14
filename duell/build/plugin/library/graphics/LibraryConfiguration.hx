/**
 * @autor rcam
 * @date 18.08.2014.
 * @company Gameduell GmbH
 */
package duell.build.plugin.library.graphics;

import haxe.io.Path;

typedef KeyValueArray = Array<{NAME : String, VALUE : String}>;


typedef LibraryConfigurationData = {
	DEPTH_TEST: Bool,
	CLEAR_COLOR_R: Float,
	CLEAR_COLOR_G: Float,
	CLEAR_COLOR_B: Float,
	CLEAR_COLOR_A: Float
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
			DEPTH_TEST: true,
			CLEAR_COLOR_R: 0.5,
			CLEAR_COLOR_G: 0.5,
			CLEAR_COLOR_B: 0.5,
			CLEAR_COLOR_A: 1.0
		};
	}
}