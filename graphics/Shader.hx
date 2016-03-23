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

package graphics;

import gl.GL.GLProgram;
import types.Data;
import graphics.GraphicsTypes;

extern class Shader
{
    public function new(): Void;
    /// Since HXSL is unstable, we will ifdef the shader code on client side.
    public var vertexShaderCode : Dynamic;
    public var fragmentShaderCode : Dynamic;

    public var uniformInterfaces : Array<ShaderUniformInterface>;

    public var attributeNames : Array<String>;

    public var programName : GLProgram;
}

extern class ShaderUniformInterface
{
    public var name : String;///purely for debugging purposes.

    public var dataCount : Int;
    public var uniformType : UniformType;
    public var shaderType : ShaderType;  /// To which shader this Const/Uniform belongs to

    public var shaderVariableName : String;

    public var data : Data;
    public var dataActiveCount : Int;

    public function new(): Void;

    /// helper function, creates the underlying data with the appropriate size
    public function setup(shaderVariableName : String, uniformType : UniformType, shaderType : ShaderType, count : Int = 1) : Void;
}