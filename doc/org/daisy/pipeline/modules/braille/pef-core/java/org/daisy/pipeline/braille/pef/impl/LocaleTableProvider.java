package org.daisy.pipeline.braille.pef.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import com.google.common.base.Optional;
import com.google.common.collect.ImmutableSet;
import org.daisy.braille.api.table.Table;

import org.daisy.pipeline.braille.common.Provider;
import static org.daisy.pipeline.braille.common.Provider.util.dispatch;
import static org.daisy.pipeline.braille.common.Provider.util.memoize;
import org.daisy.pipeline.braille.common.Query;
import org.daisy.pipeline.braille.common.Query.Feature;
import org.daisy.pipeline.braille.common.Query.MutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.mutableQuery;
import org.daisy.pipeline.braille.pef.AbstractTableProvider;
import org.daisy.pipeline.braille.pef.TableProvider;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component(
	name = "org.daisy.pipeline.braille.pef.impl.LocaleTableProvider",
	service = {
		TableProvider.class,
		org.daisy.braille.api.table.TableProvider.class
	}
)
public class LocaleTableProvider extends AbstractTableProvider {
	
	private static Set<String> supportedFeatures = ImmutableSet.of("locale");
	private static Map<String,String> tablesFromLocale = new HashMap<String,String>();
	
	public LocaleTableProvider() {
		tablesFromLocale.put("en", "org.daisy.braille.impl.table.DefaultTableProvider.TableType.EN_US");
		tablesFromLocale.put("nl", "com_braillo.BrailloTableProvider.TableType.BRAILLO_6DOT_031_01");
	}

	/**
	 * Recognized features:
	 *
	 * - locale: A locale that is mapped to a specific table
	 *     that is a sane default for that locale.
	 */
	protected Iterable<Table> _get(Query query) {
		for (Feature feature : query)
			if (!supportedFeatures.contains(feature.getKey())) {
				logger.debug("Unsupported feature: " + feature);
				return empty; }
		Iterable<Table> tables = empty;
		MutableQuery q = mutableQuery(query);
		if (q.containsKey("locale")) {
			String id = tablesFromLocale.get(q.removeOnly("locale").getValue().get());
			if (id != null) {
				q.add("id", id);
				tables = backingProvider.get(q); }}
		return tables;
	}
	
	private final static Iterable<Table> empty = Optional.<Table>absent().asSet();
	
	@Reference(
		name = "TableProvider",
		unbind = "unbindTableProvider",
		service = TableProvider.class,
		cardinality = ReferenceCardinality.MULTIPLE,
		policy = ReferencePolicy.DYNAMIC
	)
	protected void bindTableProvider(TableProvider provider) {
		if (provider != this)
			otherProviders.add(provider);
	}
		
	protected void unbindTableProvider(TableProvider provider) {
		if (provider != this) {
			otherProviders.remove(provider);
			backingProvider.invalidateCache(); }
	}
		
	private List<TableProvider> otherProviders = new ArrayList<TableProvider>();
	private Provider.util.MemoizingProvider<Query,Table> backingProvider
	= memoize(dispatch(otherProviders));
	
	private static final Logger logger = LoggerFactory.getLogger(LocaleTableProvider.class);
	
}
