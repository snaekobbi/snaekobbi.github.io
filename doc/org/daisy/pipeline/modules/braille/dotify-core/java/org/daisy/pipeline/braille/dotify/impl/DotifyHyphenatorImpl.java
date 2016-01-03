package org.daisy.pipeline.braille.dotify.impl;

import java.util.ArrayList;
import java.util.List;
import java.util.NoSuchElementException;

import org.daisy.dotify.api.hyphenator.HyphenatorConfigurationException;
import org.daisy.dotify.api.hyphenator.HyphenatorInterface;
import org.daisy.dotify.api.hyphenator.HyphenatorFactoryService;

import org.daisy.pipeline.braille.common.AbstractTransform;
import org.daisy.pipeline.braille.common.AbstractTransformProvider;
import org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Function;
import org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Iterables;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.logCreate;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.logSelect;
import org.daisy.pipeline.braille.common.Hyphenator;
import org.daisy.pipeline.braille.common.Query;
import org.daisy.pipeline.braille.common.Query.MutableQuery;
import static org.daisy.pipeline.braille.common.Query.util.mutableQuery;
import org.daisy.pipeline.braille.common.TransformProvider;
import static org.daisy.pipeline.braille.common.TransformProvider.util.varyLocale;
import org.daisy.pipeline.braille.common.util.Locales;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import org.daisy.pipeline.braille.dotify.DotifyHyphenator;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class DotifyHyphenatorImpl extends AbstractTransform implements DotifyHyphenator {
	
	private HyphenatorInterface hyphenator;
	
	protected DotifyHyphenatorImpl(HyphenatorInterface hyphenator) {
		this.hyphenator = hyphenator;
	}
	
	public HyphenatorInterface asHyphenatorInterface() {
		return hyphenator;
	}
	
	public String[] transform(String[] text) {
		String[] hyphenated = new String[text.length];
		for (int i = 0; i < text.length; i++)
			hyphenated[i] = hyphenator.hyphenate(text[i]);
		return hyphenated;
	}
	
	@Component(
		name = "org.daisy.pipeline.braille.dotify.DotifyHyphenatorImpl.Provider",
		service = {
			DotifyHyphenator.Provider.class,
			Hyphenator.Provider.class
		}
	)
	public static class Provider extends AbstractTransformProvider<DotifyHyphenator>
	                             implements DotifyHyphenator.Provider {
		
		/**
		 * Recognized features:
		 *
		 * - hyphenator: Will only match if the value is `dotify'.
		 * - locale: Required. Matches only Dotify translators for that locale. An
		 *     automatic fallback mechanism is used: if nothing is found for
		 *     language-COUNTRY-variant, then language-COUNTRY is searched, then language.
		 *
		 * No other features are allowed.
		 */
		public Iterable<DotifyHyphenator> _get(Query query) {
			MutableQuery q = mutableQuery(query);
			if (q.containsKey("hyphenator"))
				if (!"dotify".equals(q.removeOnly("hyphenator").getValue().get()))
					return empty;
			return logSelect(q, _provider);
		}
		
		private final static Iterable<DotifyHyphenator> empty = Iterables.<DotifyHyphenator>empty();
		
		private TransformProvider<DotifyHyphenator> _provider
		= varyLocale(
			new AbstractTransformProvider<DotifyHyphenator>() {
				public Iterable<DotifyHyphenator> _get(Query query) {
					MutableQuery q = mutableQuery(query);
					if (q.containsKey("locale")) {
						final String locale = Locales.toString(parseLocale(q.removeOnly("locale").getValue().get()), '-');
						if (!q.isEmpty()) {
							logger.warn("Unsupported feature '"+ q.iterator().next().getKey() + "'");
							return empty; }
						return Iterables.transform(
							factoryServices,
							new Function<HyphenatorFactoryService,DotifyHyphenator>() {
								public DotifyHyphenator _apply(HyphenatorFactoryService service) {
									try {
										if (service.supportsLocale(locale))
											return __apply(
												logCreate(
													(DotifyHyphenator)new DotifyHyphenatorImpl(service.newFactory().newHyphenator(locale)))); }
									catch (HyphenatorConfigurationException e) {
										logger.error("Could not create HyphenatorInterface for locale " + locale, e); }
									throw new NoSuchElementException();
								}
							}
						);
					}
					return empty;
				}
			}
		);
		
		private final List<HyphenatorFactoryService> factoryServices = new ArrayList<HyphenatorFactoryService>();
		
		@Reference(
			name = "HyphenatorFactoryService",
			unbind = "unbindHyphenatorFactoryService",
			service = HyphenatorFactoryService.class,
			cardinality = ReferenceCardinality.MULTIPLE,
			policy = ReferencePolicy.DYNAMIC
		)
		protected void bindHyphenatorFactoryService(HyphenatorFactoryService service) {
			factoryServices.add(service);
			invalidateCache();
		}
		
		protected void unbindHyphenatorFactoryService(HyphenatorFactoryService service) {
			factoryServices.remove(service);
			invalidateCache();
		}
		
		private static final Logger logger = LoggerFactory.getLogger(Provider.class);
		
	}
}
