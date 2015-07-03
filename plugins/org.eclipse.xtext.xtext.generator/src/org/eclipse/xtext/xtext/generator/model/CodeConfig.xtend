/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.eclipse.xtext.xtext.generator.model

import com.google.inject.Injector
import java.io.IOException
import java.io.InputStream
import java.net.URL
import java.text.SimpleDateFormat
import java.util.Date
import java.util.List
import java.util.jar.Manifest
import org.eclipse.emf.common.EMFPlugin
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.util.Strings
import org.eclipse.xtext.xtext.generator.IGuiceAwareGeneratorComponent

/**
 * Configuration object for generated code.
 */
class CodeConfig implements IGuiceAwareGeneratorComponent {

	static val FILE_HEADER_VAR_TIME = '${time}'
	static val FILE_HEADER_VAR_DATE = '${date}'
	static val FILE_HEADER_VAR_YEAR = '${year}'
	static val FILE_HEADER_VAR_USER = '${user}'
	static val FILE_HEADER_VAR_VERSION = '${version}'
	
	@Accessors
	String lineDelimiter
	
	@Accessors(PUBLIC_GETTER)
	String fileHeader
	
	String fileHeaderTemplate = "/*\n * generated by Xtext\n */"
	
	@Accessors(PUBLIC_GETTER)
	val List<IClassAnnotation> classAnnotations = newArrayList
	
	/**
	 * Configure a template for file headers. The template can contain variables:
	 * <ul>
	 *   <li><code>${time}</code> - the current time of the day (hour:minute:second)</li>
	 *   <li><code>${date}</code> - the current date (month day, year)</li>
	 *   <li><code>${year}</code> - the current year</li>
	 *   <li><code>${user}</code> - the content of the 'user.name' system property</li>
	 *   <li><code>${version}</code> - the generator plug-in version</li>
	 * </ul>
	 */
	def void setFileHeader(String fileHeaderTemplate) {
		this.fileHeaderTemplate = fileHeaderTemplate
	}
	
	/**
	 * Class annotations are used to configure specific Java annotations to be added to each generated class.
	 */
	def void addClassAnnotation(IClassAnnotation annotation) {
		this.classAnnotations.add(annotation)
	}
	
	override initialize(Injector injector) {
		injector.injectMembers(this)
		
		if (lineDelimiter === null)
			lineDelimiter = '\n'
		
		var fileHeader = fileHeaderTemplate
		if (fileHeader != null) {
			if (fileHeader.contains(FILE_HEADER_VAR_TIME)) {
				val dateFormat = new SimpleDateFormat('HH:mm:ss')
				val time = dateFormat.format(new Date)
				fileHeader = fileHeader.replace(FILE_HEADER_VAR_TIME, time)
			}
			if (fileHeader.contains(FILE_HEADER_VAR_DATE)) {
				val dateFormat = new SimpleDateFormat('MMM d, yyyy')
				val date = dateFormat.format(new Date)
				fileHeader = fileHeader.replace(FILE_HEADER_VAR_DATE, date)
			}
			if (fileHeader.contains(FILE_HEADER_VAR_YEAR)) {
				val dateFormat = new SimpleDateFormat('yyyy')
				val year = dateFormat.format(new Date)
				fileHeader = fileHeader.replace(FILE_HEADER_VAR_YEAR, year)
			}
			if (fileHeader.contains(FILE_HEADER_VAR_USER)) {
				val user = System.getProperty("user.name")
				if (user != null) {
					fileHeader = fileHeader.replace(FILE_HEADER_VAR_USER, user)
				}
			}
			if (fileHeader.contains(FILE_HEADER_VAR_VERSION)) {
				val version = getVersion()
				if (version != null) {
					fileHeader = fileHeader.replace(FILE_HEADER_VAR_VERSION, version)
				}
			}
		}
		this.fileHeader = fileHeader
	}

	/**
	 * Read the exact version from the Manifest of the plugin.
	 */
	private def getVersion() {
		var InputStream is
		try {
			val url = new URL(Plugin.INSTANCE.baseURL + 'META-INF/MANIFEST.MF')
			is = url.openStream()
			val manifest = new Manifest(is)
			return manifest.getMainAttributes().getValue('Bundle-Version')
		} catch (Exception e) {
			return null;
		} finally {
			if (is != null) {
				try { is.close() }
				catch (IOException e) {}
			}
		}
	}

	/**
	 * Only needed to determine the Manifest file and its version of this plugin in standalone mode.
	 */
	private static class Plugin extends EMFPlugin {
		public static final Plugin INSTANCE = new Plugin
		private new() {
			super(#[]);
		}
		override getPluginResourceLocator() {
		}
	}

	def String getClassAnnotationsAsString() {
		if (classAnnotations.isEmpty) {
			return null
		}
		val stringBuilder = new StringBuilder
		for (annotation : classAnnotations) {
			stringBuilder.append(annotation.toString).append(Strings.newLine)
		}
		return stringBuilder.toString
	}

	def String getAnnotationImportsAsString() {
		if (classAnnotations.isEmpty) {
			return null
		}
		val stringBuilder = new StringBuilder
		for (annotation : classAnnotations) {
			val importString = annotation.annotationImport
			if (importString !== null) {
				stringBuilder.append('import ').append(importString).append(';').append(Strings.newLine)
			}
		}
		return stringBuilder.toString
	}
	
}