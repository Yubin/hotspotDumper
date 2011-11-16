import java.io.IOException;
import java.net.MalformedURLException;
import java.util.ArrayList;

import com.google.gdata.client.douban.DoubanService;
import com.google.gdata.data.Link;
import com.google.gdata.data.PlainTextConstruct;
import com.google.gdata.data.TextContent;
import com.google.gdata.data.douban.Attribute;
import com.google.gdata.data.douban.CollectionEntry;
import com.google.gdata.data.douban.CollectionFeed;
import com.google.gdata.data.douban.MiniblogEntry;
import com.google.gdata.data.douban.MiniblogFeed;
import com.google.gdata.data.douban.NoteEntry;
import com.google.gdata.data.douban.NoteFeed;
import com.google.gdata.data.douban.ReviewEntry;
import com.google.gdata.data.douban.ReviewFeed;
import com.google.gdata.data.douban.Status;
import com.google.gdata.data.douban.Subject;
import com.google.gdata.data.douban.SubjectEntry;
import com.google.gdata.data.douban.SubjectFeed;
import com.google.gdata.data.douban.Tag;
import com.google.gdata.data.douban.TagEntry;
import com.google.gdata.data.douban.TagFeed;
import com.google.gdata.data.douban.UserEntry;
import com.google.gdata.data.douban.UserFeed;
import com.google.gdata.data.extensions.Rating;
import com.google.gdata.util.ServiceException;

public class DoubanDemo {

	public static void main(String[] args) {
		String apiKey = "059ef56f6b705e1210dce04e42511a36";
		String secret = "006ba4a489916c13";

		DoubanService myService = new DoubanService("subApplication", apiKey,
				secret);

		System.out.println("please paste the url in your webbrowser, complete the authorization then come back:");
		System.out.println(myService.getAuthorizationUrl(null));
		byte buffer[] = new byte[1];
		try {
			System.in.read(buffer);
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		myService.getAccessToken();
		//myService.setAccessToken("", "");
		
		System.out.println("User related test:");
		testUserEntry(myService);
		testUserFriends(myService);
		
		System.out.println("Subject related test:");
		testSubjectEntry(myService);
		
		System.out.println("Review related test:");
		testReviewEntry(myService);
		testWriteReviewEntry(myService);
		
		System.out.println("Collection related test:");
		testCollectionEntry(myService);
		testCollectionFeed(myService);
		testWriteCollectionEntry(myService);
		
		System.out.println("Note related test:");
		testNoteEntry(myService);
		testWriteNoteEntry(myService);
		
		System.out.println("Tag feedest:");
		testTagFeed(myService);
		
		System.out.println("Miniblog related test:");
		testMiniblogEntry(myService);
	}

	private static void testMiniblogEntry(DoubanService myService) {
		String userId = "sakinijino";
		MiniblogFeed mf;
		try {
			mf = myService.getUserMiniblogs(userId, 1, 2);
			for(MiniblogEntry me: mf.getEntries()) {
				printMiniblogEntry(me);
			}
			mf = myService.getContactsMiniblogs("apitest", 1, 2);
			for(MiniblogEntry me: mf.getEntries()) {
				printMiniblogEntry(me);
			}
			myService.createSaying(new PlainTextConstruct("Hello Douban API java client!"));
		} catch (IOException e) {
			e.printStackTrace();
		} catch (ServiceException e) {
			e.printStackTrace();
		}
	}

	private static void printMiniblogEntry(MiniblogEntry me) {
		
		if(me.getContent() != null)
			System.out.println("content is "
				+ ((TextContent) me.getContent()).getContent().getPlainText());
		
		
		System.out
				.println("title is " + me.getTitle().getPlainText());
		
		System.out.println("id is " + me.getId());
		System.out.println("published time is " + me.getPublished());
		for (Attribute attr : me.getAttributes()) {
			System.out.println(attr.getName() + " : " + attr.getContent());
		}
		
		System.out.println("-------------------");
		
	}

	private static void testTagFeed(DoubanService myService) {

		try {

			String userId = "sakinijino";
			// cat=movie&start-index=2&max-results=3
			TagFeed tf = myService.getUserTags(userId, "movie", 2, 3);
			for (TagEntry te : tf.getEntries()) {
				printTagEntry(te);
			}

			String movieId = "1424406";
			// start-index=1&max-results=10
			tf = myService.getMovieTags(movieId, 1, 10);
			for (TagEntry te : tf.getEntries()) {
				printTagEntry(te);
			}
		} catch (MalformedURLException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (ServiceException e) {
			e.printStackTrace();
		}
	}

	private static void printTagEntry(TagEntry te) {
		System.out.println("count is " + te.getCount().getContent());
		System.out.println("id is " + te.getId());
		System.out.println("title is " + te.getTitle().getPlainText());
	}

	private static void testCollectionEntry(DoubanService myService) {
		try {
			String cid = "1123456";
			
			CollectionEntry ce = myService.getCollection(cid);
			printCollectionEntry(ce);
			
		} catch (MalformedURLException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (ServiceException e) {
			e.printStackTrace();
		}
	}

	private static void testCollectionFeed(DoubanService myService) {
		try {
			String userId = "sakinijino";
			// cat=movie&start-index=1&max-results=2&tag=TimBurton
			// status=null
			CollectionFeed cf = myService.getUserCollections(userId, "movie",
					"TimBurton", null, 1, 2);
			for (CollectionEntry ce : cf.getEntries()) {
				printCollectionEntry(ce);
			}
		} catch (MalformedURLException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (ServiceException e) {
			e.printStackTrace();
		}
	}

	private static void printCollectionEntry(CollectionEntry ce) {

		System.out.println("id is " + ce.getId());
		System.out.println("title is " + ce.getTitle().getPlainText());
		if (!ce.getAuthors().isEmpty()) {
			System.out.println("author name is : "
					+ ce.getAuthors().get(0).getName());
			System.out.println("author URI is : "
					+ ce.getAuthors().get(0).getUri());
		}
		System.out.println("status is " + ce.getStatus().getContent());

		printSubjectEntry(ce.getSubjectEntry());

		Rating rating = ce.getRating();
		if (rating != null)
			System.out.println("max is " + rating.getMax() + " min is "
					+ rating.getMin() + " value is " + rating.getValue()
					+ " numRaters is " + rating.getNumRaters() + " average is "
					+ rating.getAverage());
		System.out.println("Tags:");
		for (Tag tag : ce.getTags()) {
			System.out.println(tag.getName());
		}
	}

	private static void testReviewEntry(DoubanService myService) {
		ReviewEntry reviewEntry;
		try {
			
			String reviewId = "1138468";
			reviewEntry = myService.getReview(reviewId);
			printReviewEntry(reviewEntry);

			String userId = "1026712";
			ReviewFeed reviewFeed = myService.getUserReviews(userId);
			for (ReviewEntry sf : reviewFeed.getEntries()) {
				printReviewEntry(sf);
			}
			
			String movieId = "1424406";
			// start-index=2&max-results=2
			reviewFeed = myService.getMovieReviews(movieId, 2, 2, "score");
			for (ReviewEntry sf : reviewFeed.getEntries()) {
				printReviewEntry(sf);
			}
			reviewFeed = myService.getMovieReviews(movieId, 2, 2, "time");
			for (ReviewEntry sf : reviewFeed.getEntries()) {
				printReviewEntry(sf);
			}

		} catch (IOException e) {
			e.printStackTrace();
		} catch (ServiceException e) {
			e.printStackTrace();
		}
	}

	private static void testSubjectEntry(DoubanService myService) {
		SubjectEntry subjectEntry;
		try {
			String bookId = "2023013";
			subjectEntry = myService.getBook(bookId);
			printSubjectEntry(subjectEntry);

			// tag=cowboy&start-index=1&max-results=2
			// q=null
			SubjectFeed subjectFeed = myService.findMovie(null, "cowboy", 1, 2);
			for (SubjectEntry sf : subjectFeed.getEntries()) {
				printSubjectEntry(sf);
			}
		} catch (IOException e) {
			e.printStackTrace();
		} catch (ServiceException e) {
			e.printStackTrace();
		}

	}

	private static void testNoteEntry(DoubanService myService) {
		NoteEntry noteEntry;
		NoteFeed noteFeed;
		try {
			String noteId = "17730279";
			noteEntry = myService.getNote(noteId);
			printNoteEntry(noteEntry);
			
			noteFeed = myService.getUserNotes("aka", 2, 2);
			for(NoteEntry ne: noteFeed.getEntries()) {
				printNoteEntry(ne);
			}
		} catch (IOException e) {
			e.printStackTrace();
		} catch (ServiceException e) {
			e.printStackTrace();
		}

	}

	private static void printNoteEntry(NoteEntry noteEntry) {
		if (noteEntry.getSummary() != null)
			System.out.println("summary is "
					+ noteEntry.getSummary().getPlainText());
		if(noteEntry.getContent() != null)
			System.out.println("content is "
				+ ((TextContent) noteEntry.getContent()).getContent().getPlainText());
		
		if (noteEntry.getAuthors() != null) {
			if (!noteEntry.getAuthors().isEmpty())
				System.out.println("author is "
						+ noteEntry.getAuthors().get(0).getName());
		}
		System.out
				.println("title is " + noteEntry.getTitle().getPlainText());
		/*
		for (Attribute attr : noteEntry.getAttributes()) {
			System.out.println(attr.getName() + " : " + attr.getContent());
		}*/
		//System.out.println(noteEntry.getAttributes().isEmpty());
		for (Attribute attr : noteEntry.getAttributes()) {
			System.out.println(attr.getName() + " : " + attr.getContent());
		}
		System.out.println("id is " + noteEntry.getId());
		System.out.println("-------------------");
		
	}

	private static void testUserEntry(DoubanService myService) {
		UserEntry userEntry;
		try {
			String userId = "ahbei";
			userEntry = myService.getUser(userId);
			printUserEntry(userEntry);
			
			//printUserEntry(myService.getAuthorizedUser());

			// q=douban&start-index=10&max-results=1
			UserFeed userFeed = myService.findUser("douban", 1, 1);
			for (UserEntry ue : userFeed.getEntries()) {
				printUserEntry(ue);
			}
		} catch (IOException e) {
			e.printStackTrace();
		} catch (ServiceException e) {
			e.printStackTrace();
		}
	}

	private static void printReviewEntry(ReviewEntry reviewEntry) {
		// System.out.println("content is " +
		// reviewEntry.getPlainTextContent());
		System.out.println("id is : " + reviewEntry.getId());
		System.out.println("title is : "
				+ reviewEntry.getTitle().getPlainText());
		if (!reviewEntry.getAuthors().isEmpty()) {
			System.out.println("author name is : "
					+ reviewEntry.getAuthors().get(0).getName());
			System.out.println("author URI is : "
					+ reviewEntry.getAuthors().get(0).getUri());
		}
		System.out.println("updated date is : " + reviewEntry.getUpdated());
		System.out.println("published date is : " + reviewEntry.getPublished());
		if (reviewEntry.getSummary() != null)
			System.out.println("summary is : "
					+ reviewEntry.getSummary().getPlainText());
		Rating rating = reviewEntry.getRating();
		if (rating != null)
			System.out.println("Rating : max is " + rating.getMax()
					+ " min is " + rating.getMin() + " numRaters is "
					+ rating.getNumRaters() + " average is "
					+ rating.getAverage() + " value is " + rating.getValue());

		// begin the subject info
		System.out.println("begin the subject info:");
		Subject se = reviewEntry.getSubjectEntry();
		if (se != null)
			printSubjectEntry(se);
		else
			System.out.println("no subject got");

		System.out.println("-------------------");
	}

	private static void printSubjectEntry(SubjectEntry subjectEntry) {

		if (subjectEntry.getSummary() != null)
			System.out.println("summary is "
					+ subjectEntry.getSummary().getPlainText());
		System.out.println("author is "
				+ subjectEntry.getAuthors().get(0).getName());
		System.out
				.println("title is " + subjectEntry.getTitle().getPlainText());

		for (Attribute attr : subjectEntry.getAttributes()) {
			System.out.println(attr.getName() + " : " + attr.getContent());
		}
		System.out.println("id is " + subjectEntry.getId());
		for (Tag tag : subjectEntry.getTags()) {
			System.out.println(tag.getName() + " : " + tag.getCount());
		}

		Rating rating = subjectEntry.getRating();
		if (rating != null)
			System.out.println("max is " + rating.getMax() + " min is "
					+ rating.getMin() + " numRaters is "
					+ rating.getNumRaters() + " average is "
					+ rating.getAverage());
		System.out.println("-------------------");
	}

	private static void printSubjectEntry(Subject se) {

		if (se == null)
			return;
		if (se.getSummary() != null)
			System.out.println("summary is " + se.getSummary().getPlainText());
		System.out.println("author is " + se.getAuthors().get(0).getName());
		System.out.println("title is " + se.getTitle().getPlainText());

		for (Attribute attr : se.getAttributes()) {
			System.out.println(attr.getName() + " : " + attr.getContent());
		}
		System.out.println("id is " + se.getId());
		for (Tag tag : se.getTags()) {
			System.out.println(tag.getName() + " : " + tag.getCount());
		}

		Rating rating = se.getRating();
		if (rating != null)
			System.out.println("max is " + rating.getMax() + " min is "
					+ rating.getMin() + " numRaters is "
					+ rating.getNumRaters() + " average is "
					+ rating.getAverage());
		System.out.println("********************");
	}

	private static void printUserEntry(UserEntry ue) {

		System.out.println("id is " + ue.getId());
		System.out.println("uid is " + ue.getUid());
		System.out.println("location is " + ue.getLocation());

		System.out.println("content is "
				+ ((TextContent) ue.getContent()).getContent().getPlainText());
		System.out.println("title is " + ue.getTitle().getPlainText());

		printUserEntryLinks(ue);
		System.out.println("-------------------");

	}
	
	private static void testUserFriends(DoubanService myService) {
		try {
			UserFeed uf = myService.getUserFriends("subdragon", 1, 2);
			for (UserEntry ue : uf.getEntries()) {
				printUserEntry(ue);
			}
		} catch (IOException e) {
			e.printStackTrace();
		} catch (ServiceException e) {
			e.printStackTrace();
		}

	}

	private static void printUserEntryLinks(UserEntry ue) {
		System.out.println("--Links:");
		for (Link link : ue.getLinks()) {
			System.out.println("  " + link.getRel() + " is " + link.getHref());
		}
	}

	private static void testWriteReviewEntry(DoubanService myService) {
		ReviewEntry reviewEntry;
		try {
			String movieId = "3036997"; // 立春(And the Spring Comes)

			SubjectEntry se = myService.getMovie(movieId);
			Rating rate = new Rating();
			rate.setValue(4);
			String content = "立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春";
			reviewEntry = myService.createReview(se, new PlainTextConstruct(
					"立春"), new PlainTextConstruct(content), rate);

			printReviewEntry(reviewEntry);

			myService.deleteReview(reviewEntry);

		} catch (IOException e) {
			e.printStackTrace();
		} catch (ServiceException e) {
			e.printStackTrace();
		}
	}
	private static void testWriteNoteEntry(DoubanService myService) {
		NoteEntry noteEntry;
		try {
			String content = "立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春立春";
			noteEntry = myService.createNote( new PlainTextConstruct(
					"立春"), new PlainTextConstruct(content), "public", "yes");

			printNoteEntry(noteEntry);
			String content2 = "立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋立秋";
			myService.updateNote(noteEntry, new PlainTextConstruct("立秋"), new PlainTextConstruct(content2), "public", "no");
			myService.deleteNote(noteEntry);

		} catch (IOException e) {
			e.printStackTrace();
		} catch (ServiceException e) {
			e.printStackTrace();
		}
	}

	private static void testWriteCollectionEntry(DoubanService myService) {
		try {
			CollectionEntry ce;

			Rating rating = new Rating();
			rating.setValue(4);

			ArrayList<Tag> tags = new ArrayList<Tag>(2);
			Tag t1 = new Tag();
			t1.setName("顾长卫");
			Tag t2 = new Tag();
			t2.setName("李樯");

			tags.add(t1);
			tags.add(t2);

			String movieId = "3036997"; // 立春(And the Spring Comes)
			SubjectEntry se = myService.getMovie(movieId);
			ce = myService.createCollection(new Status("watched"), se, tags,
					rating);

			printCollectionEntry(ce);

			myService.deleteCollection(ce);
		} catch (MalformedURLException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (ServiceException e) {
			e.printStackTrace();
		}
	}
}
