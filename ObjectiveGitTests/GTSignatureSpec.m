//
//  GTSignatureSpec.m
//  ObjectiveGitFramework
//
//  Created by Justin Spahr-Summers on 2013-06-26.
//  Copyright (c) 2013 GitHub, Inc. All rights reserved.
//

#import <Nimble/Nimble.h>
#import <ObjectiveGit/ObjectiveGit.h>
#import <Quick/Quick.h>

#import "QuickSpec+GTFixtures.h"

QuickSpecBegin(GTSignatureSpec)

NSString *name = @"test_user";
NSString *email = @"test@example.com";

__block NSDate *time;

qck_beforeEach(^{
	time = [NSDate date];
});

qck_describe(@"instance", ^{
	__block GTSignature *testSignature;

	qck_beforeEach(^{
		testSignature = [[GTSignature alloc] initWithName:name email:email time:time];
		expect(testSignature).notTo(beNil());
	});

	qck_it(@"should expose the git_signature", ^{
		expect([NSValue valueWithPointer:testSignature.git_signature]).notTo(equal([NSValue valueWithPointer:NULL]));
		expect(testSignature).to(equal([[GTSignature alloc] initWithGitSignature:testSignature.git_signature]));
	});

	qck_it(@"should compare equal to a signature created with the same information", ^{
		expect(testSignature).to(equal([[GTSignature alloc] initWithName:name email:email time:time]));
	});

	qck_it(@"should compare unequal to a different signature", ^{
		expect(testSignature).notTo(equal([[GTSignature alloc] initWithName:name email:email time:[NSDate dateWithTimeIntervalSinceNow:10]]));
	});
});

qck_it(@"should keep the git_signature alive even if the object goes out of scope", ^{
	const git_signature *git_signature = NULL;

	{
		GTSignature *testSignature __attribute__((objc_precise_lifetime)) = [[GTSignature alloc] initWithName:name email:email time:time];
		git_signature = testSignature.git_signature;
	}

	GTSignature *testSignature = [[GTSignature alloc] initWithGitSignature:git_signature];
	expect(testSignature.name).to(equal(name));
	expect(testSignature.email).to(equal(email));
});

qck_afterEach(^{
	[self tearDown];
});

QuickSpecEnd
