/*******************************************************************************
 * Copyright (c) 2008 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.eclipse.xtext.grammargen.tests;

import java.util.List;

import org.antlr.runtime.CommonToken;
import org.eclipse.xtext.generator.tests.AbstractGeneratorTest;
import org.eclipse.xtext.generator.tests.Invocation;

/**
 * @author Sven Efftinge - Initial contribution and API
 *
 */
public class SimpleTest extends AbstractGeneratorTest {
	
	public void testFoo() throws Exception {
		List<Invocation> parse = parse("HOLLA");
		assertEquals("create", parse.get(0).method);
		assertEquals("Foo", parse.get(0).feature);

		assertEquals("set", parse.get(1).method);
		assertEquals("name", parse.get(1).feature);
		assertEquals("HOLLA", ((CommonToken)parse.get(1).param).getText());
	}
	
	
	
	
}
