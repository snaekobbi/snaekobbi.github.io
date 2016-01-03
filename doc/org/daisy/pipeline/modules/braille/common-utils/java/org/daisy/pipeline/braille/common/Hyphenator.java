package org.daisy.pipeline.braille.common;

/**
 * Can hyphenate text.
 *
 * Hyphenating means inserting invisible format characters such as soft
 * hyphens and zero width spaces. Apart from the insertion of these characters
 * no other transformations are allowed.
 *
 */
public interface Hyphenator extends Transform {
	
	public String[] transform(String[] text);
	
	public interface Provider<T extends Hyphenator> extends TransformProvider<T> {}
	
}
