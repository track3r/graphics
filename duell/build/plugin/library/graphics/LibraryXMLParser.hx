/*
 * Copyright (c) 2003-2016, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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