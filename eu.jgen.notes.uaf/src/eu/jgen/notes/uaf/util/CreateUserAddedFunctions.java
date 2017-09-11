/**
 * [The "BSD license"]
 * Copyright (c) 2016, JGen Notes
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions 
 *    and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions 
 *    and the following disclaimer in the documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, 
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS 
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 */
package eu.jgen.notes.uaf.util;

import java.nio.file.Paths;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.ca.gen.jmmi.Ency;
import com.ca.gen.jmmi.EncyManager;
import com.ca.gen.jmmi.Model;
import com.ca.gen.jmmi.ModelManager;
import com.ca.gen.jmmi.exceptions.EncyException;
import com.ca.gen.jmmi.exceptions.ModelNotFoundException;
import com.ca.gen.jmmi.ids.ObjId;
import com.ca.gen.jmmi.schema.ObjTypeCode;
import com.google.inject.Injector;

import eu.jgen.notes.annot.desc.AnnotationStandaloneSetup;
import eu.jgen.notes.annot.desc.processor.AnnotationWorker;
import eu.jgen.notes.uaf.proc.UserAddedFunctionProcessor;

/**
 * @author Marek Stankiewicz
 *
 */

public class CreateUserAddedFunctions {

	private static final String OPT_SUBDIRECTORY_NAME = "\\notes";
	private Model model;
	private Ency ency;
	private Injector injector;
	private Map<String, String> options;

	public CreateUserAddedFunctions(Map<String, String> options) {
		this.options = options;
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		System.out.println("Utility  User-Added Function (UAF), Version 0.5");
		Map<String, String> options = new HashMap<String, String>();
		if (args.length == 2 || args.length == 3) {
			if (args.length == 3) {
				if (args[2].equals(UserAddedFunctionProcessor.OPT_FORCE)) {
					options.put(UserAddedFunctionProcessor.OPT_FORCE, args[2]) ;
				} else if (args[2].equals(UserAddedFunctionProcessor.OPT_TEST)) {
					options.put(UserAddedFunctionProcessor.OPT_TEST, args[2]) ;
				} else if (args[2].equals(UserAddedFunctionProcessor.OPT_SOURCE)) {
					options.put(UserAddedFunctionProcessor.OPT_SOURCE, args[2]) ;
				}else {
					displayHelp();
					return;
				}
			}
		} else {
			displayHelp();
			return;
		}
		
		System.out.println("Starting...");
		options.put(UserAddedFunctionProcessor.OPT_NOTES_DIRECTORY, args[0] + OPT_SUBDIRECTORY_NAME);
		options.put(UserAddedFunctionProcessor.OPT_LOCAL_NAME,  Paths.get(args[0]).getFileName().toString());
		options.put(UserAddedFunctionProcessor.OPT_CAGEN_PATH, args[1]) ;
		CreateUserAddedFunctions createUAF = new CreateUserAddedFunctions(options);
		createUAF.start(args[0]);
	}

	private static void displayHelp() {
		System.out.println("Usage:  java  -jar uaf.jar  modelpath cagenpath [ -forceall | -testonly  | -sourcesonly]");
		System.out.println("     where:");
		System.out.println("        -forceall   force clean up entire generation frastructure");
		System.out.println("        -testonly   generate test classes only");
		System.out.println("        -sourcesonly   regenerate implementation classes only");
	}

	private void start(String path) { 
		injector = new AnnotationStandaloneSetup().createInjectorAndDoEMFRegistration();
		try {
			ency = EncyManager.connectLocalForReadOnly(path);
			model = ModelManager.open(ency, ency.getModelIds().get(0));
			System.out.println("Connected to local model: " + model.getName());
			List<ObjId> list = model.getObjIds(ObjTypeCode.ACBLKBSD);
			AnnotationWorker worker = injector.getInstance(AnnotationWorker.class);
			worker.init(model, new UserAddedFunctionProcessor(), options)
					.setSources(list).activate();
			model.close();
			ency.disconnect();
			System.out.println("Processing completed.");
		} catch (EncyException e) {
			System.out.println("ERROR:  " + e.getLocalizedMessage());
		} catch (ModelNotFoundException e) {
			System.out.println("ERROR:  " + e.getLocalizedMessage());
		}
		return;
	}

}
