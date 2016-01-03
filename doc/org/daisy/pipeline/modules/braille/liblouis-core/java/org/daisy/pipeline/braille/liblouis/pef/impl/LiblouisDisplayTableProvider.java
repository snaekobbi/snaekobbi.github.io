package org.daisy.pipeline.braille.liblouis.pef.impl;

import java.util.Set;

import com.google.common.base.Function;
import com.google.common.base.Optional;
import static com.google.common.base.Predicates.notNull;
import com.google.common.collect.ImmutableSet;
import static com.google.common.collect.Iterables.filter;
import static com.google.common.collect.Iterables.transform;

import org.daisy.braille.api.factory.AbstractFactory;
import org.daisy.braille.api.table.BrailleConverter;
import org.daisy.braille.api.table.Table;

import org.daisy.pipeline.braille.common.Query;
import org.daisy.pipeline.braille.common.Query.Feature;
import org.daisy.pipeline.braille.common.Query.MutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.mutableQuery;
import org.daisy.pipeline.braille.liblouis.impl.LiblouisTableJnaImplProvider;
import org.daisy.pipeline.braille.liblouis.impl.LiblouisTableJnaImplProvider.LiblouisTableJnaImpl;
import org.daisy.pipeline.braille.pef.AbstractTableProvider;
import org.daisy.pipeline.braille.pef.TableProvider;

import org.liblouis.Translator;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component(
	name = "org.daisy.pipeline.braille.liblouis.pef.impl.LiblouisDisplayTableProvider",
	service = {
		TableProvider.class,
		org.daisy.braille.api.table.TableProvider.class
	}
)
public class LiblouisDisplayTableProvider extends AbstractTableProvider {
	
	private LiblouisTableJnaImplProvider tableProvider;
	
	@Reference(
		name = "LiblouisTableJnaImplProvider",
		unbind = "unbindLiblouisTableJnaImplProvider",
		service = LiblouisTableJnaImplProvider.class,
		cardinality = ReferenceCardinality.MANDATORY,
		policy = ReferencePolicy.STATIC
	)
	protected void bindLiblouisTableJnaImplProvider(LiblouisTableJnaImplProvider provider) {
		tableProvider = provider;
	}
	
	protected void unbindLiblouisTableJnaImplProvider(LiblouisTableJnaImplProvider provider) {
		tableProvider = null;
	}
	
	private static Set<String> supportedFeatures = ImmutableSet.of("liblouis-table", "locale");
	
	/**
	 * Recognized features:
	 *
	 * - id: Matches liblouis display tables by their fully qualified table identifier. Not
	 *     compatible with other features.
	 *
	 * - liblouis-table: A liblouis table is a URI that can be either a file name, a file path
	 *     relative to a registered tablepath, an absolute file URI, or a fully qualified table
	 *     identifier.
	 *
	 * - locale: Matches only liblouis display tables with that locale.
	 *
	 * All matched tables must be of type "display table".
	 */
	protected Iterable<Table> _get(Query query) {
		for (Feature feature : query)
			if (!supportedFeatures.contains(feature.getKey())) {
				logger.debug("Unsupported feature: " + feature);
				return empty; }
		MutableQuery q = mutableQuery(query);
		q.add("display");
		return filter(
			transform(
				tableProvider.get(q),
				new Function<LiblouisTableJnaImpl,Table>() {
					public Table apply(LiblouisTableJnaImpl table) {
						return new LiblouisDisplayTable(table.getTranslator()); }}),
			notNull());
	}
	
	private final static Iterable<Table> empty = Optional.<Table>absent().asSet();
	
	@SuppressWarnings("serial")
	private static class LiblouisDisplayTable extends AbstractFactory implements Table {
		
		final Translator table;
		
		private LiblouisDisplayTable(Translator table) {
			super("", "", table.getTable());
			this.table = table;
		}
		
		public BrailleConverter newBrailleConverter() {
			return new LiblouisDisplayTableBrailleConverter(table);
		}
		
		public void setFeature(String key, Object value) {
			throw new IllegalArgumentException("Unknown feature: " + key);
		}
		
		public Object getFeature(String key) {
			throw new IllegalArgumentException("Unknown feature: " + key);
		}
		
		public Object getProperty(String key) {
			return null;
		}
	}
		
	private static final Logger logger = LoggerFactory.getLogger(LiblouisDisplayTableProvider.class);
	
}
