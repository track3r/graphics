/**
 * @autor rcam
 * @date 18.08.2014.
 * @company Gameduell GmbH
 */
package duell.build.plugin.library.graphics;

import duell.build.objects.DuellProjectXML;
import duell.build.objects.Configuration;

import duell.build.plugin.library.graphics.LibraryConfiguration;

import duell.helpers.XMLHelper;
import duell.helpers.LogHelper;

import haxe.xml.Fast;

class LibraryXMLParser
{
	public static function parse(xml : Fast) : Void
	{
		Configuration.getData().LIBRARY.GRAPHICS = LibraryConfiguration.getData();

		for (element in xml.elements) 
		{
			if (!XMLHelper.isValidElement(element, DuellProjectXML.getConfig().parsingConditions))
				continue;

			switch(element.name)
			{
				case 'depth-test':
					parseDepthTestElement(element);
				case 'clear-color':
					parseClearColorElement(element);
			}
		}
	}

	private static function parseDepthTestElement(element : Fast)
	{
		if (element.has.value)
		{
			LibraryConfiguration.getData().DEPTH_TEST = element.att.value == "true" ? true : false;
		}
	}

	private static function parseClearColorElement(element : Fast)
	{
		if (element.has.r)
		{
			LibraryConfiguration.getData().CLEAR_COLOR_R = Std.parseFloat(element.att.r);
		}

		if (element.has.g)
		{
			LibraryConfiguration.getData().CLEAR_COLOR_G = Std.parseFloat(element.att.g);
		}

		if (element.has.b)
		{
			LibraryConfiguration.getData().CLEAR_COLOR_B = Std.parseFloat(element.att.b);
		}

		if (element.has.a)
		{
			LibraryConfiguration.getData().CLEAR_COLOR_A = Std.parseFloat(element.att.a);
		}
	}

	/// HELPERS
	private static function addUniqueKeyValueToKeyValueArray(keyValueArray : KeyValueArray, key : String, value : String)
	{
		for (keyValuePair in keyValueArray)
		{
			if (keyValuePair.NAME == key)
			{
				LogHelper.println('Overriting key $key value ${keyValuePair.VALUE} with value $value');
				keyValuePair.VALUE = value;
			}
		}

		keyValueArray.push({NAME : key, VALUE : value});
	}

	private static function resolvePath(string : String) : String /// convenience method
	{
		return DuellProjectXML.getConfig().resolvePath(string);
	}
}