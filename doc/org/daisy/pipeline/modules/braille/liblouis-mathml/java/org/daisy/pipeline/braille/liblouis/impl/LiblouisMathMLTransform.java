package org.daisy.pipeline.braille.liblouis.impl;

import java.net.URI;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import com.google.common.base.Objects;
import com.google.common.base.Objects.ToStringHelper;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;

import org.daisy.pipeline.braille.common.AbstractTransform;
import org.daisy.pipeline.braille.common.AbstractTransformProvider;
import org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Iterables;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.Iterables.of;
import static org.daisy.pipeline.braille.common.AbstractTransformProvider.util.logCreate;
import org.daisy.pipeline.braille.common.Query;
import org.daisy.pipeline.braille.common.Query.Feature;
import org.daisy.pipeline.braille.common.Transform;
import org.daisy.pipeline.braille.common.TransformProvider;
import static org.daisy.pipeline.braille.common.util.Locales.parseLocale;
import static org.daisy.pipeline.braille.common.util.URIs.asURI;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.ComponentContext;

public interface LiblouisMathMLTransform {
	
	public enum MathCode {
		NEMETH, UKMATHS, MARBURG, WOLUWE
	}
	
	@Component(
		name = "org.daisy.pipeline.braille.liblouis.impl.LiblouisMathMLTransform.Provider",
		service = {
			TransformProvider.class
		}
	)
	public class Provider extends AbstractTransformProvider<Transform> {
		
		private URI href;
		
		@Activate
		private void activate(ComponentContext context, final Map<?,?> properties) {
			href = asURI(context.getBundleContext().getBundle().getEntry("xml/translate-mathml.xpl"));
		}
		
		private final static Iterable<Transform> empty = Iterables.<Transform>empty();
		
		private final static List<String> supportedOutput = ImmutableList.of("braille");
		
		protected Iterable<Transform> _get(final Query query) {
			try {
				if ("mathml".equals(query.getOnly("input").getValue().get())) {
					for (Feature f : query.get("output"))
						if (!supportedOutput.contains(f.getValue().get()))
							return empty;
					if (query.containsKey("locale")) {
						MathCode code = mathCodeFromLocale(parseLocale(query.getOnly("locale").getValue().get()));
						if (code != null)
							return of(logCreate((Transform)new TransformImpl(code))); }}}
			catch (IllegalStateException e) {}
			return empty;
		}
		
		private class TransformImpl extends AbstractTransform {
			
			private final MathCode code;
			private final XProc xproc;
			
			private TransformImpl(MathCode code) {
				this.code = code;
				Map<String,String> options = ImmutableMap.of("math-code", code.name());
				xproc = new XProc(href, null, options);
			}
			
			@Override
			public XProc asXProc() {
				return xproc;
			}
			
			@Override
			public ToStringHelper toStringHelper() {
				return Objects.toStringHelper("o.d.p.b.liblouis.impl.LiblouisMathMLTransform$Provider$TransformImpl")
					.add("mathCode", code);
			}
		}
		
		private static MathCode mathCodeFromLocale(Locale locale) {
			String language = locale.getLanguage().toLowerCase();
			String country = locale.getCountry().toUpperCase();
			if (language.equals("en")) {
				if (country.equals("GB"))
					return MathCode.UKMATHS;
				else
					return MathCode.NEMETH; }
			else if (language.equals("de"))
				return MathCode.MARBURG;
			else if (language.equals("nl"))
				return MathCode.WOLUWE;
			else
				return null;
		}
		
	}
}
