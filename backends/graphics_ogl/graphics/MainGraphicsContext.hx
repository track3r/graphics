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

import gl.GLExtDefines;
import gl.GLExt;
import haxe.ds.Vector;
import graphics.GraphicsContext;
import gl.GL;
import gl.GLDefines;
import gl.GLContext;
import graphics.GraphicsTypes;
import haxe.ds.GenericStack;
import graphics.RenderTargetData;

import haxe.ds.GenericStack;

class MainGraphicsContext extends GraphicsContext
{
    public function new() : Void
    {
        super();
    }

    public function initialize(finishedCallback : Void->Void)
    {
        currentShader = GL.nullProgram;
        var maxActiveTextures = GraphicsContext.maxActiveTextures;
        currentActiveTexture = maxActiveTextures + 1;

        for(val in 0...maxActiveTextures)
        {
            currentActiveTextures.push(GL.nullTexture);
        }

        currentRenderTargetDataStack = new GenericStack<RenderTargetData>();
        currentLineWidth = 1;
        currentDepthTesting = false;

        GLContext.setupMainContext(function ()
        {
            glContext = GLContext.getMainContext();
            defaultRenderTargetData = new RenderTargetData();
            rebindDefaultBackbuffer();
            defaultRenderTargetData.discardColor = true;
            defaultRenderTargetData.discardDepth = true; // TODO change that the default renderTarget is initialized with just the stencil attachment
            defaultRenderTargetData.discardStencil = true;
            currentRenderTargetDataStack.add(defaultRenderTargetData);
            finishedCallback();
        });
    }
}