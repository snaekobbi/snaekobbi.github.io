package org.daisy.pipeline.braille.tex.impl;

import java.io.InputStream;
import java.io.IOException;
import java.net.URI;
import java.net.URL;
import java.util.Locale;

import org.daisy.pipeline.braille.common.AbstractTransform;
import org.daisy.pipeline.braille.common.AbstractTransformProvider;
import org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Function;
import org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Iterables;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Iterables.fromNullable;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Iterables.transform;
import org.daisy.pipeline.braille.common.Hyphenator;
import org.daisy.pipeline.braille.common.Query;
import org.daisy.pipeline.braille.common.Query.MutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.mutableQuery;
import static org.daisy.pipeline.braille.common.util.Files.isAbsoluteFile;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;
import static org.daisy.pipeline.braille.common.util.URLs.asURL;
import org.daisy.pipeline.braille.tex.TexHyphenator;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Deactivate;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component(
	name = "org.daisy.pipeline.braille.tex.impl.TexHyphenatorSimpleImpl",
	service = {
		TexHyphenator.Provider.class,
		Hyphenator.Provider.class
	}
)
public class TexHyphenatorSimpleImpl extends AbstractTransformProvider<TexHyphenator>
	                                 implements TexHyphenator.Provider {
	
	private TexHyphenatorTableRegistry tableRegistry;
	
	@Activate
	protected void activate() {
		logger.debug("Loading TeX hyphenation service");
	}
	
	@Deactivate
	protected void deactivate() {
		logger.debug("Unloading TeX hyphenation service");
	}
	
	@Reference(
		name = "TexHyphenatorTableRegistry",
		unbind = "unbindTableRegistry",
		service = TexHyphenatorTableRegistry.class,
		cardinality = ReferenceCardinality.MANDATORY,
		policy = ReferencePolicy.STATIC
	)
	protected void bindTableRegistry(TexHyphenatorTableRegistry registry) {
		tableRegistry = registry;
		logger.debug("Registering Tex hyphenation table registry: " + registry);
	}
	
	protected void unbindTableRegistry(TexHyphenatorTableRegistry registry) {
		tableRegistry = null;
	}
	
	private final static Iterable<TexHyphenator> empty = Iterables.<TexHyphenator>empty();
	
	/**
	 * Recognized features:
	 *
	 * - hyphenator: Will only match if the value is `tex' or `texhyph'.
	 *
	 * - table: A tex table is a URI that is either a file name, a file path relative to a
	 *     registered tablepath, an absolute file URI, or a fully qualified table identifier. Only
	 *     URIs that point to LaTeX pattern files (ending with ".tex") are matched. The `table'
	 *     feature is not compatible with `locale'.
	 *
	 * - locale: Matches only hyphenators with that locale.
	 *
	 * No other features are allowed.
	 */
	public Iterable<TexHyphenator> _get(Query query) {
		MutableQuery q = mutableQuery(query);
		if (q.containsKey("hyphenator")) {
			String v = q.removeOnly("hyphenator").getValue().get();
			if (!"texhyph".equals(v) && !"tex".equals(v))
				return fromNullable(fromId(v)); }
		if (q.containsKey("table")) {
			String v = q.removeOnly("table").getValue().get();
			if (!q.isEmpty()) {
				logger.warn("A query with both 'table' and '" + q.iterator().next().getKey() + "' never matches anything");
				return empty; }
			return fromNullable(get(asURI(v))); }
		Locale locale;
		if (q.containsKey("locale"))
			locale = parseLocale(q.removeOnly("locale").getValue().get());
		else
			locale = parseLocale("und");
		if (!q.isEmpty()) {
			logger.warn("A query with '" + q.iterator().next().getKey() + "' never matches anything");
			return empty; }
		if (tableRegistry != null) {
			return transform(
				tableRegistry.get(locale),
				new Function<URI,TexHyphenator>() {
					public TexHyphenator _apply(URI table) {
						return get(table); }}); }
		return empty;
	}
	
	private TexHyphenator get(URI table) {
		if (table.toString().endsWith(".tex")) {
			try { return new TexHyphenatorImpl(table); }
			catch (Exception e) {
				logger.warn("Could not create hyphenator for table " + table, e); }}
		return null;
	}
	
	private class TexHyphenatorImpl extends AbstractTransform implements TexHyphenator {
		
		private final URI table;
		private final net.davidashen.text.Hyphenator hyphenator;
		
		private TexHyphenatorImpl(URI table) throws IOException {
			this.table = table;
			hyphenator = new net.davidashen.text.Hyphenator();
			InputStream stream = resolveTable(table).openStream();
			hyphenator.loadTable(stream);
			stream.close();
		}
		
		public URI asTexHyphenatorTable() {
			return table;
		}
		
		public String[] transform(String[] text) {
			String[] hyphenated = new String[text.length];
			for (int i = 0; i < text.length; i++)
				try {
					hyphenated[i] = hyphenator.hyphenate(text[i]); }
				catch (Exception e) {
					throw new RuntimeException("Error during TeX hyphenation", e); }
			return hyphenated;
		}
	}
	
	private URL resolveTable(URI table) {
		URL resolvedTable = isAbsoluteFile(table) ? asURL(table) : tableRegistry.resolve(table);
		if (resolvedTable == null)
			throw new RuntimeException("Hyphenation table " + table + " could not be resolved");
		return resolvedTable;
	}
	
	private static final Logger logger = LoggerFactory.getLogger(TexHyphenatorSimpleImpl.class);
	
}
