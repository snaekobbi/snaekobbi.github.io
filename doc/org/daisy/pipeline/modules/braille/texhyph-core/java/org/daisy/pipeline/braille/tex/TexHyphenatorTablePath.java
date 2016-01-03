package org.daisy.pipeline.braille.tex;

import java.net.URI;
import java.net.URL;
import java.util.Locale;
import java.util.Map;

import org.daisy.pipeline.braille.common.BundledResourcePath;
import org.daisy.pipeline.braille.common.Provider;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;

import org.osgi.service.component.ComponentContext;

public class TexHyphenatorTablePath extends BundledResourcePath implements Provider<Locale,URI> {
	
	private static final String MANIFEST = "manifest";
	
	@Override
	protected void activate(ComponentContext context, Map<?,?> properties) throws Exception {
		if (properties.get(UNPACK) != null)
			throw new IllegalArgumentException(UNPACK + " property not supported");
		super.activate(context, properties);
		if (properties.get(MANIFEST) != null) {
			String manifestPath = properties.get(MANIFEST).toString();
			final URL manifestURL = context.getBundleContext().getBundle().getEntry(manifestPath);
			if (manifestURL == null)
				throw new IllegalArgumentException("Manifest at location " + manifestPath + " could not be found");
			initProvider(manifestURL); }
	}
	
	public Iterable<URI> get(Locale locale) {
		return provider.get(locale);
	}
	
	private Provider<Locale,URI> provider = Provider.util.<Locale,URI>empty();
	
	private void initProvider(URL manifestURL) {
		provider = new Provider.util.SimpleMappingProvider<Locale,URI>(manifestURL) {
			public Locale parseKey(String locale) {
				return parseLocale(locale);
			}
			public URI parseValue(String table) {
				return canonicalize(asURI(table));
			}
		};
	}
}
