package org.daisy.pipeline.braille.common;

import java.util.ArrayList;

import static com.google.common.collect.Iterators.peekingIterator;
import com.google.common.collect.Lists;
import com.google.common.collect.PeekingIterator;

public abstract class AbstractBrailleTranslator extends AbstractTransform implements BrailleTranslator {
	
	public FromStyledTextToBraille fromStyledTextToBraille() throws UnsupportedOperationException {
		throw new UnsupportedOperationException();
	}
	
	public LineBreakingFromStyledText lineBreakingFromStyledText() throws UnsupportedOperationException {
		throw new UnsupportedOperationException();
	}
	
	/* ================== */
	/*       UTILS        */
	/* ================== */
	
	public static abstract class util {
		
		public static class DefaultLineBreaker implements LineIterator {
			
			public DefaultLineBreaker(String text) {
				this(text, 1);
			}
			
			public DefaultLineBreaker(String text, int wordSpacing) {
				this(text, wordSpacing, BRAILLE_PATTERN_BLANK, '\u2824');
			}
			
			public DefaultLineBreaker(String text, int wordSpacing, char blankChar, char hyphenChar) {
				this.wordSpacing = wordSpacing;
				this.blankChar = blankChar;
				this.hyphenChar = hyphenChar;
				input = peekingIterator(Lists.charactersOf(text).iterator());
			}
			
			private final int wordSpacing;
			private final char blankChar;
			private final char hyphenChar;
			
			private final PeekingIterator<Character> input;
			private StringBuilder charBuffer = new StringBuilder();
			
			/**
			 * Array with soft wrap opportunity info
			 * - SPACE, LF, CR, TAB and ZWSP create normal soft wrap opportunities
			 * - SHY create soft wrap opportunities that insert a hyphen glyph
			 * - normal soft wrap opportunities override soft wrap opportunities that insert a hyphen glyph
			 *
			 * @see <a href="http://snaekobbi.github.io/braille-css-spec/#h3_line-breaking">Braille CSS – § 9.4 Line Breaking</a>
			 */
			private ArrayList<Byte> wrapInfo = new ArrayList<Byte>();
			private final static byte NO_SOFT_WRAP = (byte)0x0;
			private final static byte SOFT_WRAP_WITH_HYPHEN = (byte)0x1;
			private final static byte SOFT_WRAP_WITHOUT_HYPHEN = (byte)0x3;
			private final static byte SOFT_WRAP_AFTER_SPACE = (byte)0x7;
			private final static byte HARD_WRAP = (byte)0x15;
			
			private final static char SHY = '\u00ad';
			private final static char ZWSP = '\u200b';
			private final static char SPACE = ' ';
			private final static char CR = '\r';
			private final static char LF = '\n';
			private final static char TAB = '\t';
			private final static char NBSP = '\u00a0';
			private final static char BRAILLE_PATTERN_BLANK = '\u2800';
			private final static char LS = '\u2028';
			
			private boolean lastCharIsSpace = false;
			
			/**
			 * Fill the character and soft wrap opportunity buffers while normalising and collapsing spaces
			 * - until the buffers are at least 'size' long
			 * - or until the remaining input is empty
			 * - and while the remaining input starts with SPACE, LF, CR, TAB, NBSP or BRAILLE PATTERN BLANK
			 */
			private void fillBuffer(int size) {
				int bufSize = charBuffer.length();
			  loop: while (input.hasNext()) {
					char next = input.peek();
					switch (next) {
					case SHY:
						if (bufSize > 0)
							wrapInfo.set(bufSize - 1, (byte)(wrapInfo.get(bufSize - 1) | SOFT_WRAP_WITH_HYPHEN));
						lastCharIsSpace = false;
						break;
					case ZWSP:
						if (bufSize > 0)
							wrapInfo.set(bufSize - 1, (byte)(wrapInfo.get(bufSize - 1) | SOFT_WRAP_WITHOUT_HYPHEN));
						lastCharIsSpace = false;
						break;
					case SPACE:
					case LF:
					case CR:
					case TAB:
					case BRAILLE_PATTERN_BLANK:
						if (lastCharIsSpace)
							break;
						if (bufSize > 0)
							wrapInfo.set(bufSize - 1, (byte)(wrapInfo.get(bufSize - 1) | SOFT_WRAP_WITHOUT_HYPHEN));
						for (int i = 0; i < wordSpacing; i++) {
							charBuffer.append(blankChar);
							bufSize ++;
							wrapInfo.add(SOFT_WRAP_AFTER_SPACE);
						}
						lastCharIsSpace = true;
						break;
					case NBSP:
						charBuffer.append(blankChar);
						bufSize ++;
						wrapInfo.add(NO_SOFT_WRAP);
						lastCharIsSpace = false;
						break;
					case LS:
						if (bufSize > 0)
							wrapInfo.set(bufSize - 1, (byte)(wrapInfo.get(bufSize - 1) | HARD_WRAP));
						lastCharIsSpace = true;
						break;
					default:
						if (bufSize >= size) break loop;
						charBuffer.append(next);
						bufSize ++;
						wrapInfo.add(NO_SOFT_WRAP);
						lastCharIsSpace = false; }
					input.next(); }
			}
			
			/**
			 * Flush the first 'size' elements of the character and soft wrap opportunity buffers
			 * Assumes that 'size &lt;= charBuffer.length()'
			 */
			private void flushBuffer(int size) {
				charBuffer = new StringBuilder(charBuffer.substring(size));
				wrapInfo = new ArrayList<Byte>(wrapInfo.subList(size, wrapInfo.size()));
			}
			
			public boolean hasNext() {
				fillBuffer(1);
				return charBuffer.length() > 0;
			}
			
			public String nextTranslatedRow(int limit, boolean force) {
				fillBuffer(limit + 1);
				int bufSize = charBuffer.length();
				
				// always break at preserved line breaks
				for (int i = 0; i < bufSize; i++) {
					if (wrapInfo.get(i) == HARD_WRAP) {
						String rv = charBuffer.substring(0, i + 1);
						flushBuffer(i + 1);
						return rv;
					}
				}
				
				// no need to break if remaining text is shorter than line
				if (bufSize <= limit) {
					String rv = charBuffer.toString();
					charBuffer.setLength(0);
					wrapInfo.clear();
					return rv; }
				
				// break at SPACE or ZWSP
				if ((wrapInfo.get(limit - 1) & SOFT_WRAP_WITHOUT_HYPHEN) == SOFT_WRAP_WITHOUT_HYPHEN) {
					String rv = charBuffer.substring(0, limit);
					
					// strip leading SPACE in remaining text
					while (limit < bufSize && wrapInfo.get(limit) == SOFT_WRAP_AFTER_SPACE) limit++;
					flushBuffer(limit);
					return rv; }
				
				// try to break later if the overflowing characters are blank
				for (int i = limit + 1; i - 1 < bufSize && charBuffer.charAt(i - 1) == blankChar; i++)
					if ((wrapInfo.get(i - 1) & SOFT_WRAP_WITHOUT_HYPHEN) == SOFT_WRAP_WITHOUT_HYPHEN) {
						String rv = charBuffer.substring(0, limit);
						flushBuffer(i);
						return rv; }
				
				// try to break sooner
				for (int i = limit - 1; i > 0; i--) {
					
					// break at SPACE, ZWSP or SHY
					if (wrapInfo.get(i - 1) > 0) {
						String rv = charBuffer.substring(0, i);
						
						// insert hyphen glyph at SHY
						if (wrapInfo.get(i - 1) == 0x1)
							rv += hyphenChar;
						
						// strip leading SPACE in remaining text
						// NB: breaks cases where space after SHY is not from letter-spacing
						while(i < bufSize && charBuffer.charAt(i) == blankChar) i++;
						flushBuffer(i);
						return rv; }}
				
				// force hard break
				if (force) {
					String rv = charBuffer.substring(0, limit);
					flushBuffer(limit);
					return rv; }
				
				return "";
			}
			
			public String getTranslatedRemainder() {
				while (input.hasNext()) fillBuffer(1000);
				return charBuffer.toString();
			}
			
			public int countRemaining() {
				while (input.hasNext()) fillBuffer(1000);
				return charBuffer.length();
			}
		}
	}
}
